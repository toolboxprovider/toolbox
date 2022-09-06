//
//  Double+fractions.swift
//
//
//  Created by Vladislav Soroka on 13.02.2024.
//

import Foundation

public extension Double {
    
    func string(decimalPlaces: UInt) -> String {
        String(format: "%.\(decimalPlaces)f", self)
    }
    
    var twoPlacesString: String {
        string(decimalPlaces: 2)
    }
}
