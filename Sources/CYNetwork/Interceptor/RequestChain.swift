//
//  File.swift
//  
//
//  Created by Can Yoldas on 25/12/2023.
//

import Foundation

public protocol RequestChain: AnyObject {
    
    var interceptors: [Interceptor] { get set }
    
    func kickoff<T: Decodable>(request: URLRequest) async throws -> T
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
    
    public func kickoff<T: Decodable>(request: URLRequest) async throws -> T {
        guard let firstInterceptor = interceptors.first else {
            throw InterceptError.interceptorNotFound
        }
        
        var interceptedRequest: URLRequest = request
        
        return try await firstInterceptor.intercept(request: &interceptedRequest)
    }
}
