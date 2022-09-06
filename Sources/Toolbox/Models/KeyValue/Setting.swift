//
//  Setting.swift
//     
//
//  Created  on 10/25/16.
//  Copyright © 2016    All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public protocol UserDefaultsStorable {
    
    func store(for key: String)
    init?(key: String)

}

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


extension Bool : UserDefaultsStorable {
    
    public func store(for key: String) {
        UserDefaults.standard.set(self, forKey: key)
    }
    
    public init?(key: String) {
        
        guard let _ = UserDefaults.standard.object(forKey: key) else { return nil }
        
        self = UserDefaults.standard.bool(forKey: key)
    }
    
}

extension String : UserDefaultsStorable {
    
    public func store(for key: String) {
        UserDefaults.standard.set(self, forKey: key)
    }
    
    public init?(key: String) {
        
        guard let str = UserDefaults.standard.string(forKey: key) else { return nil }
        
        self = str
    }
    
}

extension Swift.Optional: UserDefaultsStorable where Wrapped : UserDefaultsStorable {
    
    public func store(for key: String) {
        
        switch self {
        case .none:
            UserDefaults.standard.set(nil, forKey: key)
        case .some(let x):
            x.store(for: key)
        }
        
    }
    
    public init?(key: String) {
        self = Wrapped(key: key)
    }
    
}

extension Data : UserDefaultsStorable {
    
    public func store(for key: String) {
        UserDefaults.standard.set(self, forKey: key)
    }
    
    public init?(key: String) {
        
        guard let x = UserDefaults.standard.data(forKey: key) else { return nil }
        
        self = x
    }
    
}

extension Date : UserDefaultsStorable {
    
    public func store(for key: String) {
        UserDefaults.standard.set(self, forKey: key)
    }
    
    public init?(key: String) {
        
        guard let x = UserDefaults.standard.object(forKey: key) as? Date else { return nil }
        
        self = x
    }
    
}

extension Double : UserDefaultsStorable {
    
    public func store(for key: String) {
        UserDefaults.standard.set(self, forKey: key)
    }
    
    public init?(key: String) {
        
        guard let _ = UserDefaults.standard.object(forKey: key) else { return nil }
        
        self = UserDefaults.standard.double(forKey: key)        
    }
    
}

extension RawRepresentable where Self.RawValue == String {
    
    public func store(for key: String) {
        UserDefaults.standard.set(self.rawValue, forKey: key)
    }
    
    public init?(key: String) {
        
        guard let str = UserDefaults.standard.string(forKey: key),
              let x: Self = Self(rawValue: str) else { return nil }
        
        self = x
    }
    
}

public extension RawRepresentable where Self.RawValue == Int {
    
    func store(for key: String) {
        UserDefaults.standard.set(self.rawValue, forKey: key)
    }
    
    init?(key: String) {
        
        let str = UserDefaults.standard.integer(forKey: key)
        
        guard let x: Self = Self(rawValue: str) else { return nil }
        
        self = x
    }
    
}

public extension Encodable where Self : UserDefaultsStorable {
    
    func store(for key: String) {
        
        let x: Data
        do {
            x = try JSONEncoder().encode(self)
        }
        catch(let e) {
            fatalError("Error encoding object \(self). Details \(e)")
        }
        
        UserDefaults.standard.setValue(x, forKey: key)
    }
    
}

public extension Decodable where Self: UserDefaultsStorable {
    
    init?(key: String) {
        
        guard let x = UserDefaults.standard.data(forKey: key) else {
            return nil }
            
        
        let t: Self
        do {
            t = try JSONDecoder().decode(Self.self, from: x)
        }
        catch(let e) {
            fatalError("Error decoding object \(x) for key \(key). Details \(e)")
        }
        
        self = t
        
    }
    
}

extension Array: UserDefaultsStorable where Element: Codable {}

extension Dictionary: UserDefaultsStorable where Key: Codable, Value: Codable {}

extension Set: UserDefaultsStorable where Element: Codable {}
