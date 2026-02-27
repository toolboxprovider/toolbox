//
//  File.swift
//  Toolbox
//
//  Created by Vladislav Soroka on 26.02.2026.
//

import Foundation
import SwiftUI

@MainActor
@Observable
public final class Effects {
    typealias Job = @Sendable @MainActor () async throws -> Void
    typealias JobWithParam<T> = @Sendable @MainActor (T) async throws -> Void
    struct ErrorPresentation {
        let title: String
        let message: String
    }
    
    private struct WorkItem: Sendable {
        let trackProgress: Bool
        let showsError: Bool
        let job: Job
    }

    var error: ErrorPresentation? = nil
    var progressCount = 0
    private var isStarted = false

    private var continuation: AsyncStream<WorkItem>.Continuation?
    private let stream: AsyncStream<WorkItem>

    public init() {
        var cont: AsyncStream<WorkItem>.Continuation?
        self.stream = AsyncStream(WorkItem.self) { c in
            cont = c
        }
        self.continuation = cont
    }

    func run(trackProgress: Bool = false, showsError: Bool = true, _ job: @escaping Job) {
        continuation?.yield(.init(trackProgress: trackProgress, showsError: showsError, job: job))
    }

    func run(trackProgress: Bool = false, showsError: Bool = true, job: @escaping Job) -> Command {
        Command { [weak self] in
            self?.run(trackProgress: trackProgress, showsError: showsError, job)
        }
    }
    
    func run<T>(trackProgress: Bool = false, showsError: Bool = true, job: @escaping JobWithParam<T>) -> CommandWith<T> {
        CommandWith { [weak self] t in
            self?.run(trackProgress: trackProgress, showsError: showsError, { try await job(t) })
        }
    }
    
    func start() async {
        guard !isStarted else { return }
        isStarted = true
        defer { isStarted = false }
        
        await withDiscardingTaskGroup { group in
            for await workItem in stream {
                if Task.isCancelled { break }
                group.addTask { [weak self] in
                    guard let self else { return }
                    
                    if workItem.trackProgress { await increment() }
                    do {
                        try await workItem.job()
                    } catch is CancellationError {
                    } catch {
                        if workItem.showsError {
                            await presentError(error)
                        }
                    }
                    if workItem.trackProgress { await decrement() }
                    
                }
            }
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
    
    private func presentError(_ er: Error) { error = mapError(er) }
    
}

public struct EffectsPresentationModifier: ViewModifier {
    @Bindable var effects: Effects

    public func body(content: Content) -> some View {
        content
            .overlay {
                if effects.progressCount > 0 {
                    ZStack {
                        Color.black.opacity(0.12)
                        ProgressView()
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

public extension View {
    func withEffects(_ effects: Effects) -> some View {
        modifier(EffectsPresentationModifier(effects: effects))
    }
}

@Observable
public final class LocalStore<State> {
    
    private(set) var state: State

    public init(state: State) {
        self.state = state
    }
    
}

public extension LocalStore {
    
    func mutate( _ mutator: (inout State) -> Void ) {
        mutator(&state)
    }
    
    func mutateCommand( _ mutator: @escaping (inout State) -> Void ) -> Command {
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
    
    func mutateCommand<T>( _ mutator: @escaping (inout State, T) -> Void ) -> CommandWith<T> {
        return CommandWith { t in
            mutator(&self.state, t)
        }
    }
}
