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
final class Effects {
    typealias Job = @Sendable @MainActor () async throws -> Void
    typealias JobWithParam<T> = @Sendable @MainActor (T) async throws -> Void
    private struct WorkItem: Sendable {
        let trackProgress: Bool
        let job: Job
    }

    var error: Error? = nil
    var progressCount = 0
    private var isStarted = false

    private var continuation: AsyncStream<WorkItem>.Continuation?
    private let stream: AsyncStream<WorkItem>

    init() {
        var cont: AsyncStream<WorkItem>.Continuation?
        self.stream = AsyncStream(WorkItem.self) { c in
            cont = c
        }
        self.continuation = cont
    }

    func run(trackProgress: Bool = false, _ job: @escaping Job) {
        continuation?.yield(.init(trackProgress: trackProgress, job: job))
    }

    func run(trackProgress: Bool = false, job: @escaping Job) -> Command {
        Command { [weak self] in
            self?.run(trackProgress: trackProgress, job)
        }
    }
    
    func run<T>(trackProgress: Bool = false, job: @escaping JobWithParam<T>) -> CommandWith<T> {
        CommandWith { [weak self] t in
            self?.run(trackProgress: trackProgress, { try await job(t) })
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
                        await presentError(error)
                    }
                    if workItem.trackProgress { await decrement() }
                    
                }
            }
        }
    }
    
    private func increment() { progressCount += 1 }
    private func decrement() { progressCount -= 1 }
    private func presentError(_ er: Error?) { error = er }
    
}

private struct EffectsPresentationModifier: ViewModifier {
    @Bindable var effects: Effects

    func body(content: Content) -> some View {
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
                "Error",
                isPresented: Binding(
                    get: { effects.error != nil },
                    set: { if !$0 { effects.error = nil } }
                )
            ) {
                Button("OK") { effects.error = nil }
            } message: {
                Text(effects.error?.localizedDescription ?? "")
            }
            .task {
                await effects.start()
            }
    }
}

extension View {
    func withEffects(_ effects: Effects) -> some View {
        modifier(EffectsPresentationModifier(effects: effects))
    }
}
