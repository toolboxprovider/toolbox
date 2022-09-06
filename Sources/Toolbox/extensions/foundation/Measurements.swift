//
//  Measurements.swift
//  Created  on 24.06.2022.
//

import Foundation

public struct LengthFormatters {

    public static let imperialLengthFormatter: LengthFormatter = {
        let formatter = LengthFormatter()
        formatter.isForPersonHeightUse = true
        formatter.unitStyle = .short//
        formatter.numberFormatter.locale = Locale(identifier: "en_US") 
        return formatter
    }()

}

public extension Measurement where UnitType : UnitLength {

    var heightOnFeetsAndInches: String {
        let measurement = self as! Measurement<UnitLength>
        let meters = measurement.converted(to: .meters).value
        return LengthFormatters.imperialLengthFormatter.string(fromMeters: meters)
    }

}
