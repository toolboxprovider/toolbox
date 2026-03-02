//
//  File.swift
//  Toolbox
//
//  Created by Vladislav Soroka on 26.02.2026.
//

import Foundation
import SwiftUI
import UIKit

@MainActor
@Observable
public final class Effects {
    public typealias Job = @Sendable @MainActor () async throws -> Void
    public typealias JobWithParam<T> = @Sendable @MainActor (T) async throws -> Void
    public typealias Unique = (id: UUID, debounce: TimeInterval?)
    public struct ErrorPresentation {
        let title: String
        let message: String
    }
    
    private struct WorkItem: Sendable {
        let trackProgress: Bool
        let showsError: Bool
        let unique: Unique?
        let job: Job
    }
    
    private enum TaskKey: Hashable {
        case unique(UUID), regular(UUID)
    }
    
    private struct ActiveTask {
        let token: UUID
        let task: Task<Void, Never>
    }

    public var error: ErrorPresentation? = nil
    public var progressCount = 0
    private var isStarted = false

    private var continuation: AsyncStream<WorkItem>.Continuation?
    private let stream: AsyncStream<WorkItem>
    private var activeTasks: [TaskKey: ActiveTask] = [:]

    public init() {
        var cont: AsyncStream<WorkItem>.Continuation?
        self.stream = AsyncStream(WorkItem.self) { c in
            cont = c
        }
        self.continuation = cont
    }

    public func run(trackProgress: Bool = false, showsError: Bool = true, unique: Unique? = nil, _ job: @escaping Job) {
        continuation?.yield(.init(trackProgress: trackProgress, showsError: showsError, unique: unique, job: job))
    }

    public func run(trackProgress: Bool = false, showsError: Bool = true, unique: Unique? = nil, job: @escaping Job) -> Command {
        Command { [weak self] in
            self?.run(trackProgress: trackProgress, showsError: showsError, unique: unique, job)
        }
    }
    
    public func run<T>(trackProgress: Bool = false, showsError: Bool = true, unique: Unique? = nil, job: @escaping JobWithParam<T>) -> CommandWith<T> {
        CommandWith { [weak self] t in
            self?.run(trackProgress: trackProgress, showsError: showsError, unique: unique, { try await job(t) })
        }
    }
    
    public func start() async {
        guard !isStarted else { return }
        isStarted = true
        defer {
            activeTasks.values.forEach { $0.task.cancel() }
            activeTasks.removeAll()
            isStarted = false
        }
        
        for await workItem in stream {
            if Task.isCancelled { break }
            let key: TaskKey
            if let unique = workItem.unique {
                key = .unique(unique.id)
                activeTasks[key]?.task.cancel()
            } else {
                key = .regular(UUID())
            }
            let token = UUID()
            let task = Task { [weak self] in
                
                do {
                    
                    if let debounce = workItem.unique?.debounce, debounce > 0 {
                        try await Task.sleep(for: .seconds(debounce))
                    }
                    if Task.isCancelled { return }
                    if workItem.trackProgress { self?.increment() }
                    defer {
                        if workItem.trackProgress { self?.decrement() }
                    }
                    try await workItem.job()
                    
                } catch is CancellationError {
                } catch {
                    if workItem.showsError {
                        self?.error = self?.mapError(error)
                    }
                }
                
                guard self?.activeTasks[key]?.token == token else { return }
                self?.activeTasks[key] = nil
                
            }
            activeTasks[key] = .init(token: token, task: task)
        }
    }
    
    
    private func increment() { progressCount += 1 }
    private func decrement() { progressCount -= 1 }
    
    private func mapError(_ er: Error) -> ErrorPresentation? {
        if case .canceled? = er as? AppError {
            return nil
        }
        if case .generic(let description)? = er as? AppError {
            return .init(title: "Error", message: description)
        }
        if let (title, message) = appConfig.customError(er) {
            return .init(title: title, message: message)
        }
        return .init(title: "Error", message: er.localizedDescription)
    }
    
    
}

public struct EffectsPresentationModifier: ViewModifier {
    @Bindable var effects: Effects

    public func body(content: Content) -> some View {
        content
            .overlay {
                if effects.progressCount > 0 {
                    ZStack {
                        Color.black.opacity(0.12)
                        ViewProgress(image: appConfig.loaderImage)
                            .padding(16)
                            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                    }
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: effects.progressCount > 0)
            .alert(
                effects.error?.title ?? "Error",
                isPresented: Binding(
                    get: { effects.error != nil },
                    set: { if !$0 { effects.error = nil } }
                )
            ) {
                Button("OK") { effects.error = nil }
            } message: {
                Text(effects.error?.message ?? "")
            }
            .task {
                await effects.start()
            }
    }
}

private struct ViewProgress: View {
    let image: UIImage?
    @State private var animateRotation = false

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .rotationEffect(.degrees(animateRotation ? 360 : 0))
                    .animation(.linear(duration: 1.2).repeatForever(autoreverses: false), value: animateRotation)
                    .onAppear {
                        animateRotation = true
                    }
                    .onDisappear {
                        animateRotation = false
                    }
            } else {
                ProgressView()
            }
        }
    }
}

#Preview {
    ViewProgress(image: nil)
}

public extension View {
    func withEffects(_ effects: Effects) -> some View {
        modifier(EffectsPresentationModifier(effects: effects))
    }
}

@Observable
public final class LocalStore<State> {
    
    private(set) public var state: State

    public init(state: State) {
        self.state = state
    }
    
}

public extension LocalStore {
    
    func mutate( _ mutator: (inout State) -> Void ) {
        mutator(&state)
    }
    
    func mutate( _ mutator: @escaping (inout State) -> Void ) -> Command {
        Command {
            mutator(&self.state)
        }
    }
    
    func mutate<T>( _ keyPath: WritableKeyPath<State, T> ) -> CommandWith<T> {
        CommandWith { t in
            self.state[keyPath: keyPath] = t
        }
    }
    
    func mutate<T>( _ keyPath: WritableKeyPath<State, T?> ) -> CommandWith<T> {
        return CommandWith { t in
            self.state[keyPath: keyPath] = t
        }
    }
    
    func mutate<T>( _ keyPath: WritableKeyPath<State, T>, default d: T ) -> CommandWith<T?> {
        return CommandWith { t in
            self.state[keyPath: keyPath] = t ?? d
        }
    }
    
    func mutate<T>( _ mutator: @escaping (inout State, T) -> Void ) -> CommandWith<T> {
        return CommandWith { t in
            mutator(&self.state, t)
        }
    }
}
