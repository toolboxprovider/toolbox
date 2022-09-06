//
//  UIColor+hex.swift
//  Loadboard
//
//  Created  on 09.12.2021.
//

import UIKit

public extension UIColor {
  /**
   A convenience initializer that creates color from
   argb(alpha red green blue) hexadecimal representation.
   - Parameter argb: An unsigned 32 bit integer. E.g 0xFFAA44CC.
   */
  convenience init(argb: UInt32) {
    let a = argb >> 24
    let r = argb >> 16
    let g = argb >> 8
    let b = argb >> 0
    
    func f(_ v: UInt32) -> CGFloat {
      return CGFloat(v & 0xff) / 255
    }
    
    self.init(red: f(r), green: f(g), blue: f(b), alpha: f(a))
  }
  
  
  /**
   A convenience initializer that creates color from
   rgb(red green blue) hexadecimal representation with alpha value 1.
   - Parameter rgb: An unsigned 32 bit integer. E.g 0xAA44CC.
   */
  convenience init(hex rgb: UInt32) {
    self.init(argb: (0xff000000 as UInt32) | rgb)
  }
    
    var hexRGB: UInt32 {
        
        let components = cgColor.converted(to: .init(name: CGColorSpace.sRGB)!,
                                           intent: .defaultIntent, options: nil)!.components
//        let a = 0xff << 24
        let r = UInt32((components?[safe: 0] ?? 0.0) * 255) << 16
        let g = UInt32((components?[safe: 1] ?? 0.0) * 255) << 8
        let b = UInt32((components?[safe: 2] ?? 0.0) * 255) << 0
        
//        print(String(format:"%02X", a)
//        print(String(format:"%02X", r))
//        print(String(format:"%02X", g))
//        print(String(format:"%02X", b))
//
        return /*a |*/ r | g | b
        
     }
    
}
