//
//  Collection+Safe.swift
//
//  Created  on 9/5/19.
//  Copyright ©. All rights reserved.
//

import Foundation

public extension Collection {
    
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

@available(iOS 13.0, *)
public extension Array where Element: Identifiable {
    
    func element(match: Element.ID) -> (value: Element, index: Self.Index)? {
        if let x = firstIndex(where: { $0.id == match }) {
            return (self[x], x)
        }
        
        return nil
    }
    
    func updated( match: Element.ID, update: (inout Element) -> Void ) -> Array<Element> {
        
        if let (value, index) = element(match: match) {
            var accounts = self
            var element = value
            update(&element)
            accounts[index] = element
            
            return accounts
        }
        
        return self
    }
    
    mutating func update( match: Element.ID, update: (inout Element) -> Void ) {
        self = self.updated(match: match, update: update)
    }
    
    ///updates or appneds into tail
    mutating func upsert( element: Element ) {
        if let (_, i) = self.element(match: element.id) {
            self[i] = element
        } else {
            append(element)
        }
    }
 
    ///@parameter circular, if true first is returned next after last
    func next(after: Element.ID, circular: Bool = false) -> Element? {
        guard let i = element(match: after)?.index else {
            return nil
        }
        
        return self[safe: i+1] ?? (circular ? first : nil)
    }
    
    subscript (id id: Element.ID) -> Element? { element(match: id)?.value }
    
}

public extension Array {

    func pairs() -> [(Element, Element?)] {
        var result = [(Element, Element?)]()
        var i = 0
        while let x = self[safe: i] {
            result.append( (x, self[safe: i+1] ) )
            i+=2
        }
        return result
    }
    
    subscript (circular index: Int) -> Element? {
        if isEmpty { return nil }
        return self[ index % count ]
    }
}

public extension Dictionary {
    
    func retreive(ids: [Key] ) -> [Value] {
        ids.compactMap { id in
            
            guard let x = self[id] else {
                #if DEBUG
                    print("Inconsistent state, trying to access \(id) that does not exist in store")
                #endif
                return nil
            }
             
            return x
            
        }
    }
    
}

public extension Array where Element: Identifiable {
    
    func retreive(ids: [Element.ID] ) -> [Element] {
        ids.compactMap { id in
            
            guard let x = self.element(match: id)?.value else {
                #if DEBUG
                    print("Inconsistent state, trying to access \(id) that does not exist in store")
                #endif
                return nil
            }
             
            return x
            
        }
    }
 
    subscript (matching index: Element.ID) -> Element? {
        return element(match: index)?.value
    }
    
}

public extension SetAlgebra {
    
    mutating func invert(element: Element) {
        if contains(element) {
            remove(element)
        } else {
            insert(element)
        }
    }
    
    func inverted(element: Element) -> Self {
        var copy = self
        copy.invert(element: element)
        return copy
    }
    
}

public extension Array {
    
    func dayGroupped(_ map: (Element) -> Date ) -> [[Element]] {
        let res = Dictionary(grouping: self,
                             by: { Int( map($0).timeIntervalSince1970) / (24 * 60 * 60) })
                      .sorted { (lhs, rhs) in lhs.key > rhs.key }
        
        return res.map { $0.value }
    }
}

extension Array {
    
    @inlinable public subscript(safe r: ClosedRange<Self.Index>) -> Self.SubSequence {
        
        guard self.indices.contains(r.lowerBound) else { return SubSequence() }
        
        guard self.indices.contains(r.upperBound) else {
            return self.suffix(from: r.lowerBound)
        }
        
        return self[r]
    }
    
}
