//
//  DefaultDecodable.swift
//
//
//  Created .
//  Copyright © All rights reserved.
//

import Foundation

///https://www.swiftbysundell.com/tips/default-decoding-values/

extension DecodableDefault {
    public typealias True = Wrapper<Sources.True>
    public typealias False = Wrapper<Sources.False>
    public typealias EmptyString = Wrapper<Sources.EmptyString>
    public typealias EmptyInt = Wrapper<Sources.EmptyInt>
    public typealias EmptyDouble = Wrapper<Sources.EmptyDouble>
    public typealias EmptyDate = Wrapper<Sources.EmptyDate>
    public typealias EmptyList<T: List> = Wrapper<Sources.EmptyList<T>>
    public typealias EmptyMap<T: Map> = Wrapper<Sources.EmptyMap<T>>
    public typealias EmptyOptional<T: Decodable> = Wrapper<Sources.EmptyOptional<T>>
    
}

extension DecodableDefault {
    public typealias Source = DecodableDefaultSource
    public typealias List = Decodable & ExpressibleByArrayLiteral
    public typealias Map = Decodable & ExpressibleByDictionaryLiteral

    public enum Sources {
        public enum True: Source {
            public static var defaultValue: Bool { true }
        }

        public enum False: Source {
            public static var defaultValue: Bool { false }
        }

        public enum EmptyInt: Source {
            public static var defaultValue: Int { 0 }
        }
        
        public enum EmptyDouble: Source {
            public static var defaultValue: Double { 0 }
        }
        
        public enum EmptyString: Source {
            public static var defaultValue: String { "" }
        }
        
        public enum EmptyDate: Source {
            public static var defaultValue: Date { Date(timeIntervalSince1970: 0) }
        }

        public enum EmptyList<T: List>: Source {
            public static var defaultValue: T { [] }
        }

        public enum EmptyMap<T: Map>: Source {
            public static var defaultValue: T { [:] }
        }
        
        public enum EmptyOptional<T: Decodable>: Source {
            public static var defaultValue: T? { nil }
        }
        
    }
}

public protocol DecodableDefaultSource {
    associatedtype Value: Decodable
    static var defaultValue: Value { get }
}

public enum DecodableDefault {}
public extension DecodableDefault {
    @propertyWrapper
    struct Wrapper<Source: DecodableDefaultSource> {
        public typealias Value = Source.Value
        public var wrappedValue = Source.defaultValue
        
        public init(wrappedValue: Value) {
            self.wrappedValue = wrappedValue
        }
        
        public init() { }
    }
}

extension DecodableDefault.Wrapper: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        wrappedValue = try container.decode(Value.self)
    }
}

public extension KeyedDecodingContainer {
    func decode<T>(_ type: DecodableDefault.Wrapper<T>.Type,
                   forKey key: Key) throws -> DecodableDefault.Wrapper<T> {
        try decodeIfPresent(type, forKey: key) ?? .init()
    }
    
}

extension DecodableDefault.Wrapper: Equatable where Value: Equatable {}
extension DecodableDefault.Wrapper: Hashable where Value: Hashable {}

extension DecodableDefault.Wrapper: Encodable where Value: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }
}
