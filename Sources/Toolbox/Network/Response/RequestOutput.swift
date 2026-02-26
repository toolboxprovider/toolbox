//
//  BaseResponse.swift
//  
//
//  Created  on 03.01.2020.
//  Copyright © 2020 . All rights reserved.
//

import Foundation

import Alamofire
import RxSwift

public protocol RequestOutput {
    
    associatedtype T
    
    func urlRequest() async throws -> Alamofire.DataRequest
    
}

public struct ConcreteRequest<T>: RequestOutput {
    
    let x: Alamofire.DataRequest
    
    public func urlRequest() async throws -> DataRequest {
        return x
    }
    
}

public extension RequestOutput where T: Decodable {
    
    func plainResponse() async throws -> T {
        let (data, _) = try await bottleNeck()
        return try appConfig.network!.networkDecoder.decode(T.self, from: data)
    }
    
    func rxPlainResponse() -> Single<T> {
        return .fromAsync(f: plainResponse)
    }
    
}

public extension RequestOutput where T == Void {
    
    func emptyResponse() async throws -> Void {
        let _ = try await bottleNeck()
    }
    
    func rxEmptyResponse() -> Single<Void> {
        return rxBottleNeck().map { _ in }
    }
    
}

public extension RequestOutput where T == Data {
    
    func rawResponse() async throws -> (T, HTTPURLResponse?) {
        try await bottleNeck()
    }
    
}

public extension RequestOutput {
    
    func bottleNeck( ) async throws -> (body: Data, response: HTTPURLResponse?) {
        return try await bottleNeck( customHandling: false )
    }
    
    func bottleNeck( customHandling: Bool ) async throws -> (body: Data, response: HTTPURLResponse?) {
        let request = try await urlRequest()
        // Create a nonisolated(unsafe) copy so it can be referenced in the @Sendable onCancel closure
        nonisolated(unsafe) let requestForCancellation = request
        
        return try await withTaskCancellationHandler {
            return try await withCheckedThrowingContinuation { continuation in
                request
                    .validate()
                    .responseData(emptyResponseCodes: [200, 204, 205]) { (response: AFDataResponse<Data>) in

                        if customHandling, let x = response.data, let r = response.response {
                            return continuation.resume(with: .success((x, r)))
                        }
                        
                        if let e = response.error {
                            
                            if let customError = appConfig.network?.customErrorMapper?(e, response.data ?? Data()) {
                               
                                continuation.resume(throwing: customError)
                                return;
                            }
                            
                            continuation.resume(throwing: e)
                            return
                        }
                        
                        guard let mappedResponse = response.value else {
                            fatalError("Result is not success and not error")
                        }
                        
                        continuation.resume(returning: (mappedResponse, response.response))
                    }
            }
        } onCancel: {
            requestForCancellation.cancel()
        }

    }
    
    fileprivate func rxBottleNeck(  ) -> Single<(body: Data, response: HTTPURLResponse?)> {
        
        Single.fromAsync(f: bottleNeck )
        
    }
    
}

public typealias Func<T, U> = (T) async throws -> U

public extension Single {
    
    static func fromAsync( f: @escaping Func<Void, Element> ) -> Single<Element> {
        
        return Single.create { (subscriber) -> Disposable in
            
            let t = Task {
                
                do {
                    let res = try await f( () )
                    await MainActor.run {
                        subscriber(.success(res))
                    }
                } catch {
                    await MainActor.run {
                        subscriber(.failure(error))
                    }
                }
                
            }
            
            return Disposables.create {
                t.cancel()
            }
        }
        
    }
    
}

