//
//  Rx+ToImperative.swift
//  
//
//  Created  on 23.04.2021.
//  Copyright © 2021. All rights reserved.
//

import Foundation
import RxSwift

public extension ObservableConvertibleType {
    
    func toImperative( callback: @escaping (Element?, Error?) -> Void ) {
        
        let _ =
        self.asObservable().subscribe(onNext: { x in
            callback(x, nil)
        }, onError: { er in
            callback(nil, er)
        })
        
    }
    
    func toImperativeEmpty( callback: @escaping (Error?) -> Void ) {
        
        let _ =
        self.asObservable().subscribe(onNext: { x in
            callback(nil)
        }, onError: { er in
            callback(er)
        })
        
    }
    
}
