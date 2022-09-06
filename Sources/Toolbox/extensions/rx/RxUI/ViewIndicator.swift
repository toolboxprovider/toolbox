//
//  ViewIndicator.swift
//  ReactiveApp
//
//  Created by SVYAT on 08.02.16.
//  Copyright © 2016 Svyatoslav Reshetnikov. All rights reserved.
//  Inspired by Krunoslav Zaher
//

import UIKit
import RxSwift
import RxCocoa

public struct ViewToken<E>: ObservableConvertibleType, Disposable {
    private let _source: Observable<E>
    private let _dispose: Disposable
    
    init(source: Observable<E>, disposeAction: @escaping () -> ()) {
        _source = source
        _dispose = Disposables.create(with: disposeAction)
    }
    
    public func dispose() {
        _dispose.dispose()
    }
    
    public func asObservable() -> Observable<E> {
        return _source
    }
}

/**
 Enables monitoring of sequence computation.
 
 If there is at least one sequence computation in progress, `true` will be sent.
 When all activities complete `false` will be sent.
 */
public class ViewIndicator {
    
    private let _lock = NSRecursiveLock()
    private let _variable = BehaviorRelay(value: 0)
    private let _loading: Driver<Bool>
    
    public init() {
        _loading = _variable.asObservable()
            .map { $0 > 0 }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)
    }
    
    public func trackView<O: ObservableConvertibleType>(source: O) -> Observable<O.Element> {
        return Observable.using({ () -> ViewToken<O.Element> in
            self.increment()
            return ViewToken(source: source.asObservable(), disposeAction: self.decrement)
            }) { t in
                return t.asObservable()
        }
    }
    
    private func increment() {
        _lock.lock()
        _variable.accept( _variable.value + 1)
        _lock.unlock()
    }
    
    private func decrement() {
        _lock.lock()
        _variable.accept( _variable.value - 1)
        _lock.unlock()
    }
    
    public func asDriver() -> Driver<Bool> {
        return _loading
    }
    
}

public extension ObservableConvertibleType {
    
    func trackOnViewController(_ viewController: UIViewController?) -> Observable<Element> {
        return trackView(viewIndicator: viewController?.rx.viewIndicator)
    }
    
    func trackView(viewIndicator: ViewIndicator?) -> Observable<Element> {
        guard let i = viewIndicator else { return self.asObservable() }
        return i.trackView(source: self)
    }
}

public extension UIActivityIndicatorView {
    
    var rxex_animating: AnyObserver<Bool> {
        return AnyObserver { event in
            MainScheduler.ensureExecutingOnScheduler()
            
            switch (event) {
            case .next(let value):
                if value {
                    self.startAnimating()
                    self.isHidden = false
                } else {
                    self.stopAnimating()
                    self.isHidden = true
                }
            case .error( _): fallthrough
            case .completed:
                break
            }
        }
    }
    
}
