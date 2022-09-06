//
//  File.swift
//  
//
//  Created  on 31.10.2022.
//

import UIKit

open class GradientButton: UIButton {
    
    private weak var gradientLayer: CALayer?
    
    public func addGradient(fromHexColor from: UInt32, toHexColor: UInt32, horizontal: Bool = true) {
        gradientLayer = addLinearGradient(fromHexColor: from, toHexColor: toHexColor, horizontal: horizontal)
    }
    
    public func addGradient(fromColor from: UIColor, toColor: UIColor, horizontal: Bool = true) {
        gradientLayer = addLinearGradient(fromColor: from, toColor: toColor, horizontal: horizontal)
    }
  
    public override func layoutSublayers(of layer: CALayer) {
        
        gradientLayer?.frame = self.bounds
        
        super.layoutSublayers(of: layer)
    }
    
}

open class GradientLabel: UILabel {
    
    public weak var gradientLayer: CALayer?
    
    public override func layoutSublayers(of layer: CALayer) {
        
        gradientLayer?.frame = self.bounds
        
        super.layoutSublayers(of: layer)
    }
    
}

open class GradientView: UIView {
    
    private weak var gradientLayer: CALayer?
    
    public func addGradient(fromHexColor from: UInt32, toHexColor: UInt32, horizontal: Bool = true) {
        gradientLayer = addLinearGradient(fromHexColor: from, toHexColor: toHexColor, horizontal: horizontal)
    }
    
    public func addGradient(fromColor from: UIColor, toColor: UIColor, horizontal: Bool = true) {
        gradientLayer = addLinearGradient(fromColor: from, toColor: toColor, horizontal: horizontal)
    }
    
    public override func layoutSublayers(of layer: CALayer) {
        
        gradientLayer?.frame = self.bounds
        
        super.layoutSublayers(of: layer)
    }
    
}

public extension UIView {

    @discardableResult func addLinearGradient(fromColor from: UIColor, toColor: UIColor, horizontal: Bool = true) -> CALayer {
        
        return addLinearGradient(fromColor: from, toColor: toColor,
                                 startPoint: !horizontal ? CGPoint(x: 0.5, y: 0) : CGPoint(x: 0, y: 0.5),
                                 endPoint: !horizontal ? CGPoint(x: 0.5, y: 1) : CGPoint(x: 1, y: 0.5))
    
    }
    
    @discardableResult func addLinearGradient(fromHexColor from: UInt32, toHexColor: UInt32, horizontal: Bool = true) -> CALayer {

        return addLinearGradient(fromColor: UIColor(hex: from),
                                 toColor: UIColor(hex: toHexColor),
                                 horizontal: horizontal)
    }

    struct Gradient {
        public init(color: CGColor, location: NSNumber) {
            self.color = color
            self.location = location
        }
        
        let color: CGColor
        let location: NSNumber
    }
    
    @discardableResult func addLinearGradient(fromColor from: UIColor, toColor: UIColor, startPoint: CGPoint, endPoint: CGPoint) -> CALayer {
        addLinearGradient(gradients: [
            .init(color: from.cgColor, location: 0.0),
            .init(color: toColor.cgColor, location: 1.0) ],
                          startPoint: startPoint, endPoint: endPoint)
    }
    
    @discardableResult func addLinearGradient(gradients: [Gradient], startPoint: CGPoint, endPoint: CGPoint) -> CALayer {
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.layer.bounds;
        
        gradientLayer.colors = gradients.map(\.color)
        gradientLayer.locations = gradients.map(\.location)
        
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        
        gradientLayer.cornerRadius = self.layer.cornerRadius;
        self.layer.insertSublayer(gradientLayer, at: 0)
        
        return gradientLayer
        
    }
    
}

import SnapKit
public extension UIView {
    
    @discardableResult
    func embed<T: UIView>(view: T) -> T {
        addSubview(view)
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return view
    }
    
}

public extension CALayer {
    struct SketchShadow {
        public init(color: UIColor = .black, alpha: Float = 0.5, x: CGFloat = 0, y: CGFloat = 2, blur: CGFloat = 4, spread: CGFloat = 0) {
            self.color = color
            self.alpha = alpha
            self.x = x
            self.y = y
            self.blur = blur
            self.spread = spread
        }
        
        let color: UIColor
        let alpha: Float
        let x: CGFloat
        let y: CGFloat
        let blur: CGFloat
        let spread: CGFloat
    }
    
    func applySketch(shadow: SketchShadow) {
        masksToBounds = false
        shadowColor = shadow.color.cgColor
        shadowOpacity = shadow.alpha
        shadowOffset = CGSize(width: shadow.x, height: shadow.y)
        shadowRadius = shadow.blur / 2.0
        if shadow.spread == 0 {
            shadowPath = nil
        } else {
            let dx = -shadow.spread
            let rect = bounds.insetBy(dx: dx, dy: dx)
            shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }
}

class ShadowContainerView: UIView {
    
    var sketchShadow: CALayer.SketchShadow? {
        didSet {
            guard let shadow = sketchShadow else { return }
            layer.applySketch(shadow: shadow)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let shadow = sketchShadow else { return }
        
        if shadow.spread == 0 {
            layer.shadowPath = nil
        } else {
            let dx = -shadow.spread
            let rect = bounds.insetBy(dx: dx, dy: dx)
            layer.shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }
    
}
