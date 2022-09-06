//
//  Alamofire+Rx.swift
//
//  Created  on 1/9/19.
//  Copyright © 2019. All rights reserved.
//

import Foundation

import Alamofire
import RxSwift

public enum DownloadStatus<T> {
    case initialise
    case progress(Double)
    case data(T)
    case error(Error)
}

public extension Reactive where Base == DownloadRequest {
    
    func download(shouldUseRxErrors: Bool = false) -> Observable<DownloadStatus<URL>> {
        
        return Observable.create { (subscriber) -> Disposable in
            
            subscriber.onNext(.initialise)
            
            self.base.downloadProgress(closure: { (progress) in
                subscriber.onNext( .progress(progress.fractionCompleted) )
            })
            .responseURL { response in
                if let e = response.error {
                    
                    if shouldUseRxErrors { subscriber.onError(e) }
                    else {
                        subscriber.onNext( .error(e) )
                        subscriber.onCompleted()
                    }
                    
                    return
                }
                
                guard let path = response.fileURL else {
                    fatalError("Download task has neither error nor result. \(response)")
                }
                
                subscriber.onNext( .data( path ) )
                subscriber.onCompleted()
            }
            
            return Disposables.create {
                self.base.cancel()
            }
            
        }
        
    }
    
    func justDownload(shouldUseRxErrors: Bool = false) -> Single<URL> {
        return download(shouldUseRxErrors: shouldUseRxErrors)
            .filter { x in
                switch x {
                case .initialise, .progress: return false
                case .error(_), .data(_): return true
                }
            }
            .map { x in
                switch x {
                case .initialise, .progress: fatalError("unsupported")
                case .error(let e): throw e
                case .data(let url): return url
                }
            }
            .take(1)
            .asSingle()
    }
    
}

public extension DownloadRequest {
    
    var rx: Reactive<DownloadRequest> {
        return Reactive(self)
    }
    
}
