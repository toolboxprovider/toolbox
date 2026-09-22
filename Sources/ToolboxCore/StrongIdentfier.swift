//
//  StrongIdentfier.swift
//
//  Created  on 22.12.2021.
//

import Foundation

public typealias StringIdentifier<T> = Identifier<T, String>
public typealias IntIdentifier<T>    = Identifier<T, Int>

public struct Identifier<T, ID: Codable&Equatable&Hashable>: Hashable, Equatable {
    public init(rawValue: ID) {
        self.rawValue = rawValue
    }
    
    public let rawValue: ID
        
}

extension Identifier: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        rawValue = try container.decode(ID.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

extension Identifier: CustomStringConvertible where ID: CustomStringConvertible {
    public var description: String {
        return rawValue.description
    }
}

extension Identifier: ExpressibleByStringLiteral where ID == String {
    public init(stringLiteral value: String) {
        rawValue = value
    }
    
    public static var random: Self { .init(rawValue: UUID().uuidString) }
}

extension Identifier: ExpressibleByUnicodeScalarLiteral where ID == String {}
extension Identifier: ExpressibleByExtendedGraphemeClusterLiteral where ID == String {}
