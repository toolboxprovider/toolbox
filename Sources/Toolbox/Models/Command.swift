import Foundation

/// Command is a developer friendly wrapper around a closure
/// Every command always have Void result type, which do it less composable,
/// but also more focused
final public class CommandWith<T> {
    private let action: (T) -> () // underlying closure
    
    // Block of `context` defined variables. Allows Command to be debugged
    private let file: StaticString
    private let function: StaticString
    private let line: Int
    private let id: String
    
    public init(id: String = "unnamed",
         file: StaticString = #file,
         function: StaticString = #function,
         line: Int = #line,
         action: @escaping (T) -> ()) {
        self.id = id
        self.action = action
        self.function = function
        self.file = file
        self.line = line
    }
    
    public func callAsFunction(with value: T) {
        action(value)
    }
    
    public func perform(with value: T) {
        action(value)
    }
    
    /// Placeholder for do nothing command
    public static var nop: CommandWith { return CommandWith(id: "nop") { _ in } }
    
    /// Support for Xcode quick look feature.
    @objc
    func debugQuickLookObject() -> AnyObject? {
        return """
            type: \(String(describing: type(of: self)))
            id: \(id)
            file: \(file)
            function: \(function)
            line: \(line)
            """ as NSString
    }
}

/// Less code = less errors
public typealias Command = CommandWith<Void>

/// Also pure simplification
public extension CommandWith where T == Void {
    func perform() {
        perform(with: ())
    }
}

public extension CommandWith {
    static var printCommand: CommandWith {
        return CommandWith { print($0) }
    }
}

/// Allows commands to be compared and stored in sets and dicts.
/// Uses `ObjectIdentifier` to distinguish between commands
extension CommandWith: Hashable {
    public static func ==(left: CommandWith, right: CommandWith) -> Bool {
        return ObjectIdentifier(left) == ObjectIdentifier(right)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(hashValue)
    }
    
}

public extension CommandWith {
    /// Allows to pin some value to some command
    func bind(to value: T) -> Command {
        return Command { self.perform(with: value) }
    }
}

public extension CommandWith {
    func map<U>(transform: @escaping (U) -> T) -> CommandWith<U> {
        return CommandWith<U> { u in self.perform(with: transform(u)) }
    }
}

public extension CommandWith {
    // Allows to easily move commands between queues
    func dispatched(on queue: DispatchQueue) -> CommandWith {
        return CommandWith { value in
            queue.async {
                self.perform(with: value)
            }
        }
    }
}

public struct NamedCommandWith<T>: Equatable {
    public let name: String
    public let command: CommandWith<T>
    
    public init(_ name: String, action: @escaping (T) -> Void) {
        self.name = name
        self.command = .init(action: action)
    }
    
    public init(_ name: String, command: CommandWith<T>) {
        self.name = name
        self.command = command
    }
    
    public func performWith(_ value: T) {
        command(with: value)
    }
    
    public static var nop: Self {
        return .init("", command: .nop)
    }
    
}

public typealias NamedCommand = NamedCommandWith<Void>

public extension NamedCommand {
    func perform() {
        command.perform()
    }
}

public struct BooleanCommandWith<T>: Equatable {
    public let boolean: Bool
    public let command: CommandWith<T>
    
    public init(_ boolean: Bool, action: @escaping (T) -> Void) {
        self.boolean = boolean
        self.command = .init(action: action)
    }
    
    public init(_ boolean: Bool, command: CommandWith<T>) {
        self.boolean = boolean
        self.command = command
    }
    
    public func performWith(_ value: T) {
        command(with: value)
    }
    
    public static var nop: Self {
        return .init(false, command: .nop)
    }
    
}

public typealias BooleanCommand = BooleanCommandWith<Void>

public extension BooleanCommand {
    func perform() {
        command.perform()
    }
}

import UIKit
public extension UIViewController {
    var push: CommandWith<UIViewController> {
        return .init { [weak n = self.navigationController] target in
            n?.pushViewController(target,
                                  animated: true)
        }
    }
    
    var present: CommandWith<UIViewController> {
        return .init { [weak self] target in
            self?.present(target, animated: true, completion: nil)
        }
    }
    
    var dismiss: Command {
        return .init { [weak n = self] target in
            n?.dismiss(animated: true)
        }
    }
}

import SwiftUI

public struct StateCommand<T>: Hashable where T: Hashable {
    let state: T
    let change: CommandWith<T>
    public var swiftUIBinding: Binding<T> {
        Binding(
            get: { state },
            set: { change(with: $0) }
        )
    }

    public static func == (lhs: StateCommand<T>, rhs: StateCommand<T>) -> Bool {
        lhs.state == rhs.state
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(state)
    }
}

public extension StateCommand where T == Bool {
    
    func toggle() {
        change.perform(with: !state)
    }
    
}

public extension Array where Element: Hashable {
    
    func convert( select: CommandWith<Element> ) -> [StateCommand<Element>] {
        map { StateCommand(state: $0, change: select) }
    }
    
}
