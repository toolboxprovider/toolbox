//
//  Var.swift
//     
//
//  Created  on 10/5/16.
//  Copyright © 2016    All rights reserved.
//

import RxSwift
import RxCocoa

public protocol OptionalEquivalent {
    associatedtype WrappedValueType
    func unwrap() -> WrappedValueType
    func isNotNil() -> Bool
}

extension Optional: OptionalEquivalent {
    public typealias WrappedValueType = Wrapped
    
    public func unwrap() -> Wrapped {
        return self.unsafelyUnwrapped
    }
    
    public func isNotNil() -> Bool {
        
        switch self {
        case .none:
            return false
        case .some(_):
            return true
        }
        
    }
}

public extension ObservableType where Element: OptionalEquivalent {
    
    func notNil() -> Observable<Element.WrappedValueType> {
        
        return self.asObservable()
            .filter { $0.isNotNil() }
            .map { $0.unwrap() }
        
    }
    
}

public extension SharedSequenceConvertibleType where SharingStrategy == DriverSharingStrategy, Element: OptionalEquivalent {
    
    func notNil() -> Driver<Element.WrappedValueType> {
        
        return self
            .filter { $0.isNotNil() }
            .map { $0.unwrap() }
            
    }
    
}

public extension BehaviorSubject {
    
    var unsafeValue: Element {
        return try! value()
    }
    
}

public extension BehaviorRelay {
    
    var _value: Element {
        get {
            return self.value
        }
        set {
            self.accept(newValue)
        }
    }
    
}
