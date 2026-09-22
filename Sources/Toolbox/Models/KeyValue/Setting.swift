//
//  Setting.swift
//     
//
//  Created  on 10/25/16.
//  Copyright © 2016    All rights reserved.
//

import Foundation
import ToolboxCore
import RxSwift
import RxCocoa

public struct Setting<T: UserDefaultsStorable> {
    
    public var value: T {
        get {
            return variableValue.value
        }
        set {
            variableValue.accept(newValue)
        }
        
    }
    
    public var observable: Observable<T> {
        return variableValue.asObservable()
    }
    
    fileprivate let variableValue: BehaviorRelay<T>
    fileprivate let bag = DisposeBag()
    
    public init (key: String, initialValue: T) {
        
        variableValue = BehaviorRelay( value: T(key: key) ?? initialValue )
        
        variableValue.asObservable()
            .skip(1) /// no need to encode initial value
            .subscribe(onNext: { (newValue) in
                
                newValue.store(for: key)
                UserDefaults.standard.synchronize()
                
            })
            .disposed(by: bag)
    }
    
}

public struct DiskSetting<T: Codable> {
    
    public var value: T {
        get {
            return variableValue.value
        }
        set {
            variableValue.accept(newValue)
        }
        
    }
    
    public var observable: Observable<T> {
        return variableValue.asObservable()
    }
    
    fileprivate let variableValue: BehaviorRelay<T>
    fileprivate let bag = DisposeBag()
    
    public init (key: String, initialValue: T) {
        
        let url = FileManager.default
            .urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("store_\(key)")
        
        let x: T
        if let d = try? Data(contentsOf: url),
           let v = try? JSONDecoder().decode(T.self, from: d) {
            x = v
        } else {
            x = initialValue
        }
        
        variableValue = BehaviorRelay( value: x )
        
        variableValue.asObservable()
            .skip(1) /// no need to encode initial value
            .subscribe(onNext: { (newValue) in
                
                guard let x = try? JSONEncoder().encode(newValue) else {
                    return
                }
                
                try? x.write(to: url)
                
            })
            .disposed(by: bag)
    }
    
}
