//
//  ProgressView.swift
//     
//
//  Created  on 10/11/16.
//  Copyright © 2016    All rights reserved.
//

import UIKit

public class SpinnerView : UIImageView {
    
    convenience init() {
        self.init(image: appConfig.loaderImage)
        
        let animationDuration: CFTimeInterval = 1.6
        let linearCurve = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        animation.fromValue = 0
        animation.toValue = Double.pi * 2
        animation.duration = animationDuration
        animation.timingFunction = linearCurve
        animation.isRemovedOnCompletion = false
        animation.repeatCount = Float.greatestFiniteMagnitude
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.autoreverses = false
        layer.add(animation, forKey: "rotate")
        
        backgroundColor = UIColor.clear
    }
    
}
