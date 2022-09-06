//
//  UIView+RxProgressIndicator.swift
//  
//
//  Created  on 24.12.2021.
//

import UIKit
import RxSwift
import ObjectiveC

fileprivate var rxIndicatorContext: UInt8 = 1

public extension Reactive where Base: UIView {
    
    /// a unique ViewIndicator that is related to the Reactive.Base instance only for Reference type
    var viewIndicator: ViewIndicator {
        get {
            return synchronizedBag {
                if let x = objc_getAssociatedObject(base, &rxIndicatorContext) as? ViewIndicator {
                    return x
                }
                
                let i = ViewIndicator()
                
                i.asDriver()
                    .drive(onNext: { [weak b = base] (loading) in
                        b?.setLoadingStatus(loading)
                    })
                    .disposed(by: base.rx.disposeBag)
                
                objc_setAssociatedObject(base, &rxIndicatorContext, i, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return i
            }
        }
        
        set {
            synchronizedBag {
                objc_setAssociatedObject(base, &rxIndicatorContext, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
}

public extension Reactive where Base: UIViewController {
    var viewIndicator: ViewIndicator { base.view.rx.viewIndicator }
}
