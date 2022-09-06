//
//  Base.swift
//
//  Created .
//  Copyright ©
//

import Foundation

public protocol AppStateT: Codable, UserDefaultsStorable {
    
    static var `default`: Self { get }
    
}

///Syncrhonous action
public protocol ReduxAction {
    associatedtype T: AppStateT
    
    func apply(to state: inout T )
}

public extension ReduxAction {
    
    func dispatch(into store: App.Store<T>) {
        store.dispatch(action: self)
    }
    
}
