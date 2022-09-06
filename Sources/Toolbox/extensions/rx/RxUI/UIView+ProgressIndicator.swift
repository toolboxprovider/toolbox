//
//  UIView+ProgressIndicator.swift
//     
//
//  Created  on 10/11/16.
//  Copyright © 2016    All rights reserved.
//

import UIKit
import RxCocoa
import SnapKit

/**
 *  Usage -- myView.progressDriver = driverForLongOperation
 */

public extension UIView {
    
    /**
     *  @discussion - funtion for binding Driver to indicateProgress property.
     */
    func bindProgresIndicatorTo(driver: Driver<Bool>) {
        driver.drive (onNext: { [unowned self] indicator in
            self.indicateProgress = indicator
        }).disposed(by: self.rx.disposeBag)
    }

    /**
     * @discussion - you can also enable/disable animation manually
     */
    var indicateProgress: Bool {
        get {
            return self.progressView.isHidden
        }
        set {
            let pv = self.progressView
            
            UIView.animate(withDuration: 0.3) {
                pv.alpha = newValue ? 1 : 0
            }
        }
    }
    
    var indicateProgressPercent: Int? {
        get { fatalError("indicateProgressPercent is setOnly property") }
        set {
            guard let value = newValue else {
                indicateProgress = false
                return
            }
            
            indicateProgress = true
            
            progressView.progressLabel.text = "\(value) %"
        }
    }
}


public extension UIView {

    ///not the best solution, though.
    ///On heavy layots recursive search for view with tag might be expensive
    fileprivate var progressViewHash: Int {
        return "com.progressHash".hash
    }
    
    fileprivate class ProgressContainer: UIView {
        var progressLabel: UILabel!
    }

    fileprivate var progressView: ProgressContainer {

        if let pv = self.subviews.filter({ $0.tag == self.progressViewHash }).first as? ProgressContainer {
            return pv
        }

        let fantasyLoadingView = SpinnerView()
        
        let container = ProgressContainer()
        container.isUserInteractionEnabled = true
        container.alpha = 0;
        container.tag = self.progressViewHash;

        let dimmedView = UIView();
        dimmedView.backgroundColor = UIColor.black
        dimmedView.alpha = appConfig.loaderBackgroundAlpha;

        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center

        container.addSubview(dimmedView)
        container.addSubview(fantasyLoadingView)
        container.addSubview(label)
        self.addSubview(container)

        container.progressLabel = label
        
        if self is UIScrollView {
            positionOnScrollView(container: container,
                                 dimmedView: dimmedView,
                                 spinner: fantasyLoadingView,
                                 label: label)
        }
        else {
            positionOnStaticView(container: container,
                                 dimmedView: dimmedView,
                                 spinner: fantasyLoadingView,
                                 label: label)
        }
        
        return container
    }
 
    private func positionOnScrollView(container: UIView,
                                      dimmedView: UIView,
                                      spinner: UIView,
                                      label: UILabel) {
        
        guard let scrollView = self as? UIScrollView else {
            fatalError("self is not a scrollView subpublic class")
        }
        
        let _ =
        scrollView.rx.sentMessage(#selector(UIView.layoutSubviews))
            .subscribe(onNext: { [unowned sv = scrollView] (_) in
                
                sv.bringSubviewToFront(container)
                
                container.frame = CGRect(origin: sv.contentOffset, size: sv.frame.size)
                dimmedView.frame = container.bounds
                spinner.center = CGPoint(x: dimmedView.center.x,
                                         y: dimmedView.center.y - sv.contentInset.bottom / 2 )
                label.frame = CGRect(x: 0,
                                     y: spinner.frame.origin.y + spinner.bounds.size.height + 8,
                                     width: sv.frame.size.width,
                                     height: 20)
                
        })
        
    }
    
    private func positionOnStaticView(container: UIView,
                                      dimmedView: UIView,
                                      spinner: UIView,
                                      label: UILabel) {
        spinner.snp.makeConstraints { make in
            make.center.equalTo(container)
            make.height.equalTo(spinner.bounds.size.height)
            make.width.equalTo(spinner.bounds.size.width)
        }
        
        label.snp.makeConstraints { make in
            make.top.equalTo(spinner.snp.bottom).offset(8)
            make.centerX.equalTo(spinner.snp.centerX)
        }
        
        dimmedView.snp.makeConstraints { make in
            make.edges.equalTo(container)
        }
        
        container.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
    }
}
