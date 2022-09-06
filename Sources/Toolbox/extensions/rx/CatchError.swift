//
//  CatchError.swift
//     
//
//  Created  on 10/15/16.
//  Copyright © 2016    All rights reserved.
//

import Foundation
import RxSwift
import UIKit

public extension ObservableConvertibleType {

    private var identifier: String { return "com.rx.public extensions.erroridentifier" }
    
    func silentCatch(handler: UIViewController?, callback: Command = .nop) -> Observable<Element> {
        
        return self.asObservable()
            .map { Swift.Result<Self.Element, Error>.success($0) }
            .catch { [weak h = handler] (error) -> Observable<Swift.Result<Element, Error>> in
            
                DispatchQueue.main.async {
                    h?.present(error: error, callback: callback)
                }
                
                return .empty()
            }
            .filter {
                switch $0 {
                case .success(_): return true
                case .failure(_): return false
                }
                
            }
            .map {
                switch $0 {
                case .success(let val): return val
                case .failure(_): fatalError("Shouldn't have recovered from filter")
                }
        }
    }

    func silentCatch() -> Observable<Element> {
        return silentCatch(handler: nil as UIViewController?)
    }
    
}
