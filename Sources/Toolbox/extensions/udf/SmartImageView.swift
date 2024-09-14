//  SmartImageView.swift
//  Created  on 29.10.2022.

import UIKit
import RxSwift

public protocol SmartImageResource {
    var pointsTo: String { get }
}

public class SmartImageView: UIImageView, StackableView {

    public struct Props: StackableProp {
        
        public enum Image {
            case url(SmartImageResource?)
            case value(UIImage)
        };
        public let image: Image
        
        public enum Placeholder {
            case image(UIImage)
            case initials(String)
        };
        public var placeholder: Placeholder?
        public let preferredHeight: CGFloat?
        
        public init(image: SmartImageView.Props.Image,
                    placeholder: Placeholder? = nil,
                    preferredHeight: CGFloat? = nil) {
            self.image = image
            self.placeholder = placeholder
            self.preferredHeight = preferredHeight
        }
        
        public static var initial: Props { .init(image: .url(nil)) }
        
    }; public var props: Props = .initial {
        didSet {
            render()
        }
    }
    
    func render() {
        
        var im: UIImage?
        switch props.placeholder {
        case .image(let x):
            im = x
            layer.borderColor = UIColor.clear.cgColor
            layer.borderWidth = 0
            label.isHidden = true
            
        case .initials(let x):
            im = nil
            layer.borderColor = appConfig.initialsStyle.color.cgColor
            layer.borderWidth = 1
            label.isHidden = false
            label.text = x.split(separator: " ")
                .compactMap { $0.first.map(String.init) }
                .joined()
                .uppercased()
            
        case .none:
            im = nil
            layer.borderColor = UIColor.clear.cgColor
            layer.borderWidth = 0
            label.isHidden = true
        }
        
        switch props.image {
        case .value(let i):
            image = i
            
        case .url(let u):
            rx.download(url: u?.pointsTo, placeholder: im)
                .subscribe(onCompleted: { [weak self] in
                    if self?.image != nil {
                        self?.label.isHidden = true
                        self?.layer.borderColor = UIColor.clear.cgColor
                    }
                })
                .disposed(by: bag)
            
        }
        
        if let x = props.preferredHeight {
            snp.remakeConstraints { make in
                make.height.equalTo(x)
            }
        }
    }
    
    lazy var label: UILabel = {
        let x = UILabel()
        x.font = appConfig.initialsStyle.font
        x.textColor = appConfig.initialsStyle.color
        x.textAlignment = .center
        embed(view: x)
        return x
    }()
    
    var bag = DisposeBag()
    
    public func prepareForReuse() {
        bag = DisposeBag()
    }
    
}

extension SmartImageView.Props {
    
    public var nibView: UIView {
        let x = SmartImageView()
        x.props = self
        return x
    }
    
}

extension String: SmartImageResource {
    public var pointsTo: String { self }
}

extension URL: SmartImageResource {
    public var pointsTo: String { absoluteString }
}
