//
//  File.swift
//  
//
//  Created by Can Yoldas on 25/12/2023.
//

import Foundation

public protocol RequestChain: AnyObject {
    
    var interceptors: [Interceptor] { get set }
    
    func kickoff<Request: HTTPRequest>(
        request: Request,
        completion: @escaping (Result<Request.Data, Error>) -> Void
    )
}

public class NetworkInterceptChain: RequestChain {
    public enum InterceptError: String, LocalizedError {
        case interceptorNotFound = "There is no interceptor available."
    }
    
    public var interceptors: [Interceptor]
    
    public init(
        interceptors: [Interceptor]
    ) {
        self.interceptors = interceptors
    }
    
    public func kickoff<Request: HTTPRequest>(
        request: Request,
        completion: @escaping (Result<Request.Data, Error>) -> Void
    ) {
        guard let firstInterceptor = interceptors.first else {
//            throw InterceptError.interceptorNotFound
            return
        }
        
//        firstInterceptor
        
//        var interceptedRequest: URLRequest = request
        
//        return try await firstInterceptor.intercept(request: &interceptedRequest)
    }
}
