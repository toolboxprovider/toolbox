//
//  ProgressView.swift
//     
//
//  Created  on 10/11/16.
//  Copyright © 2016    All rights reserved.
//

import UIKit

public final class SpinnerView: UIView {
    
    public convenience init() {
        self.init(loaderImage: appConfig.loaderImage)
    }

    public init(loaderImage: UIImage?) {
        super.init(frame: .zero)
        backgroundColor = .clear

        if let loaderImage {
            let imageView = UIImageView(image: loaderImage)
            imageView.frame = CGRect(origin: .zero, size: loaderImage.size)
            imageView.backgroundColor = .clear
            addSubview(imageView)
            frame = imageView.frame
            addRotationAnimation(to: imageView.layer)
        } else {
            let indicator = UIActivityIndicatorView(style: .large)
            indicator.startAnimating()
            indicator.frame = CGRect(origin: .zero, size: indicator.intrinsicContentSize)
            addSubview(indicator)
            frame = indicator.frame
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func addRotationAnimation(to layer: CALayer) {
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
    }
    
}
