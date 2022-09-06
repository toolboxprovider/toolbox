//
//  Enivironment.swift
//  
//
//  Created  on 7/11/19.
//  Copyright © 2019. All rights reserved.
//

import Foundation

public enum RunScheme {
}; public extension RunScheme {
    
    static var debug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    static var adhoc: Bool {
        #if ADHOC
        return true
        #else
        return false
        #endif
    }
    
    static var isTestflight: Bool {
        return Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
    }
    
    static var appstore: Bool {
        #if DEBUG || ADHOC
        return false
        #else
        return !isTestflight
        #endif
    }
    
}
