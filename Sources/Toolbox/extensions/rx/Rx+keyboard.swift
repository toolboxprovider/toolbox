//
//  Rx+keyboard.swift
//  
//
//  Created  on 03.09.2021.
//  Copyright © 2021. All rights reserved.
//

#if os(iOS)

import UIKit
import RxSwift

public struct KeyboardChange {
    public let height: CGFloat
    public let animationDuration: Double
    
}

public extension Reactive where Base: UIView {
    
    var keyboadChange: Observable<KeyboardChange> {

        let inset = base.safeAreaInsets.bottom
        
        let show = NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
            .map { n -> KeyboardChange in
                let height = (n.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height

                let animationDuration = n.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
                
                return KeyboardChange(height: height - inset,
                                      animationDuration: animationDuration)
            }
        
        let hide = NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
            .map { n -> KeyboardChange in
                
                let animationDuration = n.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
                
                return KeyboardChange(height: 0,
                                      animationDuration: animationDuration)
            }
        
        return Observable.merge([show, hide])
        
    }
    
}

#endif
