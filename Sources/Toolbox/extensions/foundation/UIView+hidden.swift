//
//  File.swift
//  
//
//  Created by Vladislav Soroka on 08.01.2023.
//

import UIKit

public extension UIView {
    
    var isVisible: Bool {
        get { !isHidden }
        set { isHidden = !newValue }
    }
    
}
