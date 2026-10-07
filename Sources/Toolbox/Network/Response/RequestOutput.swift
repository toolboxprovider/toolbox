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
    
    public init(x: Alamofire.DataRequest) {
        self.x = x
    }
    
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
        return Single.create {
            try await plainResponse()
        }
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

        let response = await request
            .validate()
            .serializingData(emptyResponseCodes: [200, 204, 205])
            .response

        if customHandling, let data = response.data, let httpResponse = response.response {
            return (data, httpResponse)
        }

        do {
            return (try response.result.get(), response.response)
        } catch {
            if let mapped = appConfig.network?.customErrorMapper?(error, response.data ?? Data()) {
                throw mapped
            }

            throw error
        }
    }
    
    fileprivate func rxBottleNeck(  ) -> Single<(body: Data, response: HTTPURLResponse?)> {
        
        Single.create {
            try await bottleNeck()
        }
        
    }
    
}
