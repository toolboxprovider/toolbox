//
//  Created  on 7/22/17.
//  Copyright © 2017   All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

public protocol BaseRequest {
    associatedtype T
    
    func response() async throws -> T
}
public extension BaseRequest {
    func rxResponse() -> Single<T> {
        .fromAsync(f: response)
    }
}

public extension BaseRequest {
    
    ///when using [String: Any]
    func anonymousRequest<T>(baseURL: URLConvertible? = nil,
                             method: Alamofire.HTTPMethod,
                             path: String,
                             headers: [String: String]? = nil,
                             params: Parameters? = nil,
                             encoding: ParameterEncoding = JSONEncoding.default,
                             form: ((MultipartFormData) -> Void)? = nil) -> ConcreteRequest<T> {
        
        return bottleNeck(baseURL: baseURL, method: method, path: path, headers: headers, form: form) { (request) in
            request = try encoding.encode(request, with: params?.mapValues { x in
                
                if let d = x as? Date {
                    let data = try! appConfig.network!.networkEncoder.encode(d)
                    return String(data: data, encoding: .utf8)!
                }
                
                return x
            })
        }
        
    }
    
    ///when using Encodable
    func anonymousRequest<T, S>(baseURL: URLConvertible? = nil,
                                method: Alamofire.HTTPMethod,
                                path: String,
                                headers: [String: String]? = nil,
                                encodableParams: S? = nil) -> ConcreteRequest<T> where S: Encodable {
        
        return bottleNeck(baseURL: baseURL, method: method, path: path, headers: headers, form: nil) { (request) in
            request = try JSONParameterEncoder(encoder: appConfig.network!.networkEncoder).encode(encodableParams, into: request)
        }
        
    }

    func personilisedRequest<T>(baseURL: URLConvertible? = nil,
                                method: Alamofire.HTTPMethod,
                                path: String,
                                headers: [String: String]? = nil,
                                params: Parameters? = nil,
                                encoding: ParameterEncoding = JSONEncoding.default,
                                form: ((MultipartFormData) -> Void)? = nil) async throws -> ConcreteRequest<T> {
        let signedHeaders = try await personilisedRequestBottleNeck(path: path, headers: headers)
        return self.anonymousRequest(baseURL: baseURL,
                                     method: method,
                                     path: path,
                                     headers: signedHeaders,
                                     params: params,
                                     encoding: encoding,
                                     form: form)
            
    }
    
    func personilisedRequest<T: Encodable, S>(baseURL: URLConvertible? = nil,
                                              method: Alamofire.HTTPMethod,
                                              path: String,
                                              headers: [String: String]? = nil,
                                              encodableParam: T? = nil) async throws -> ConcreteRequest<S> {
        
        let signedHeaders = try await personilisedRequestBottleNeck(path: path, headers: headers)
        return self.anonymousRequest(baseURL: baseURL,
                                     method: method,
                                     path: path,
                                     headers: signedHeaders,
                                     encodableParams: encodableParam)
        
    }
    
    private func personilisedRequestBottleNeck( path: String,
                                                headers: [String: String]?) async throws -> [String: String] {
        var headers = headers ?? [:]
        await appConfig.network?.authRequestHeaders?(&headers)
        return headers
    }
               
    private func bottleNeck<T>(baseURL: URLConvertible? = nil,
                               method: Alamofire.HTTPMethod,
                               path: String,
                               headers: [String: String]? = nil,
                               form: ((MultipartFormData) -> Void)?,
                               encoding: (inout URLRequest) throws -> Void ) ->  ConcreteRequest<T> {
     
        guard var url = try? baseURL?.asURL() ?? (try? appConfig.network?.baseNetworkURL.asURL()) else {
            fatalError("Can't make requests without base URL. Please provide one in AppConfig")
        }
        
        if !path.isEmpty {
            url = url.appendingPathComponent(path)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.timeoutInterval = 30
        request.cachePolicy = appConfig.network?.cachePolicy ?? .useProtocolCachePolicy
        
        if let h = headers {
            for (key, value) in h {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        else {
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        do {
            try encoding(&request)
        }
        catch (let error) {
            fatalError("Error encoding request \(request) details - \(error)")
        }
        
        let session = appConfig.network?.session ?? AF
        
        if let form = form {
            return ConcreteRequest(x: session.upload(multipartFormData: form, with: request))
        }
        
        return ConcreteRequest(x: session.request(request) )
    }
}


