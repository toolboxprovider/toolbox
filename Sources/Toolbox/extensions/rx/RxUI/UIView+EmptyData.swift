//
//  UIView+EmptyData.swift
//
//
//  Created  on 12/18/16.
//  Copyright © 2016. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

public extension Reactive where Base: EmptyView {
    
    var isEmpty: Binder<Bool> {
        return Binder(self.base) { view, isEmpty in
            view.isEmpty = isEmpty
        }
    }

    var emptyView: Binder<UIView> {
        return Binder(self.base) { view, emptyView in
            view.emptyView = emptyView
        }
    }
    
}

public class EmptyView: UIView {

    /**
     * @discussion - you can also enable/disable animation manually
     */
    
    public var isEmpty: Bool = false {
        didSet {
            
            UIView.animate(withDuration: 0.3) {
                self.emptyView?.alpha = self.isEmpty ? 1 : 0
            }
        }
    }
    
    public var emptyView: UIView? {
        didSet {
            subviews.forEach { $0.removeFromSuperview() }
            
            guard let newView = emptyView else { return }
            
            newView.alpha = 0
            addSubview(newView)
            
            newView.snp.makeConstraints { (make) in
                make.center.equalTo(self)
                make.left.equalToSuperview().offset(16)
            }
        }
    }
    
    public var rx: Reactive<EmptyView> {
        return Reactive(self)
    }
}

public extension UIView {
    
    func addEmptyView() -> EmptyView {
        let ev = EmptyView()
        
        if let s = self as? UITableView {
            s.backgroundView = ev
        }
        else if let s = self as? UICollectionView {
            s.backgroundView = ev
        }
        else {
            addSubview(ev)
        }
        
        return ev
    }
    
}
