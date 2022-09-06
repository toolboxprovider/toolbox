//
//  AnimationStatus.swift
//     
//
//  Created  on 10/15/16.
//  Copyright © 2016
//  All rights reserved.

import UIKit
import RxSwift

public protocol ProgressAnimatable {
    
    func setLoadingStatus(_ status: Bool)
    
}

extension UIViewController: ProgressAnimatable {
    
    public func setLoadingStatus(_ status: Bool) {
    
        if self.isViewLoaded {
            view.indicateProgress = status
        } else {
            let _ = rx
                .sentMessage(#selector(UIViewController.viewDidLoad))
                .subscribe( onNext: { [unowned self] _ in self.view.indicateProgress = status })
        }
        
    }
    
}

extension UIView: ProgressAnimatable {
    
    public func setLoadingStatus(_ status: Bool) {
        
        self.indicateProgress = status
        
    }
    
}
