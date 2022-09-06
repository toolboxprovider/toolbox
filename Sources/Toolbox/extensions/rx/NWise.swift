//
//  NWise.swift
//
//  Created  on 1/11/19.
//  Copyright © 2019 
//

import Foundation
import RxSwift

public extension ObservableType {
    func nwise(_ n: Int) -> Observable<[Element]> {
        return self
            .scan([]) { acc, item in Array((acc + [item]).suffix(n)) }
            .filter { $0.count == n }
    }
    
    func pairwise() -> Observable<(Element, Element)> {
        return self.nwise(2)
            .map { ($0[0], $0[1]) }
    }
    
    func ternate() -> Observable<(Element, Element, Element)> {
        return self.nwise(3)
            .map { ($0[0], $0[1], $0[2]) }
    }
}

///https://www.youtube.com/watch?v=p3zo4ptMBiQ&t=2231s
public protocol DynamicEquatable {
    func isEqual(_ other: DynamicEquatable) -> Bool
}
extension DynamicEquatable where Self: Equatable {
    func isEqual(_ other: DynamicEquatable) -> Bool {
        if let o = other as? Self { return self == o }
        return false
    }
}

public protocol DynamicIdentifiable {
    var id: String { get }
}
extension DynamicIdentifiable where Self: Identifiable {}


public struct Diff<T> {
    public let removed: [T]
    public let added: [T]
}

public struct FullDiff<T: Sequence>: Equatable where T.Element: Identifiable & Equatable {
    
    public let removed: [T.Element]
    public let added: [T.Element]
    public let changed: [T.Element]
    
    public init(from: T, to: T) {
        
        let fromMap = Dictionary(uniqueKeysWithValues: from.map { ($0.id, $0) })
        let toMap   = Dictionary(uniqueKeysWithValues: to.map { ($0.id, $0) })
        
        let fromSet = Set(fromMap.keys)
        let toSet = Set(toMap.keys)
        
        removed = fromSet.subtracting(toSet).map { fromMap[$0]! }
        added = toSet.subtracting(fromSet).map { toMap[$0]! }
        
        changed = toSet.intersection(fromSet).compactMap { i in
            let old = fromMap[i]
            let new = toMap[i]
            
            if old != new { return new }
            
            return nil
        }
        
    }
    
}

public extension ObservableType where Element: Sequence & ExpressibleByArrayLiteral, Element.Element: Equatable & Identifiable {
    
    func diff(  ) -> Observable<FullDiff<Element>> {
        
        return self.scan([]) { acc, item in Array((acc + [item]).suffix(2)) }
            .map { x in
                
                if x.count == 1 { return FullDiff(from: [], to: x[0]) }
                
                return FullDiff(from: x[0], to: x[1])
            }
            .distinctUntilChanged()
            
    }
    
}
