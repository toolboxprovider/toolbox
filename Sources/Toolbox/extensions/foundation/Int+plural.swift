//
//  Int+plural.swift
//
//  Created  on 08.01.2020.
//  Copyright ©. All rights reserved.
//

import Foundation

public extension Int {
    
    ///Method returns countable string based on amount of number for given noun
    ///If self == 1 than it would return "1 apple"
    ///But if self == 3 => "3 apples"
    func countableString(withSingularNoun noun: String) -> String {
        
        if self == 1 {
            return "\(self) \(noun)"
        }
        
        return "\(self) \(noun)s"
        
    }
    
}
