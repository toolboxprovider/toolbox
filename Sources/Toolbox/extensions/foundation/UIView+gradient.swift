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
        var color: UIColor = .black
        var alpha: Float = 0.5
        var x: CGFloat = 0
        var y: CGFloat = 2
        var blur: CGFloat = 4
        var spread: CGFloat = 0
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
