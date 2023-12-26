//
//  File.swift
//  
//
//  Created by Can Yoldas on 25/12/2023.
//

import Foundation

public protocol RequestChain: AnyObject {
    
    var interceptors: [Interceptor] { get set }
    
    func kickoff<Request>(
        request: Request,
        completion: @escaping (Result<Request.Data, Error>) -> Void
    ) where Request: HTTPRequest
    
    func handleErrorAsync<Request>(
      _ error: Error,
      request: Request,
      response: HTTPResponse<Request>?,
      completion: @escaping (Result<Request.Data, Error>) -> Void
    ) where Request : HTTPRequest
}

public class NetworkInterceptChain: RequestChain {
  
    
    public enum InterceptError: String, LocalizedError {
        case interceptorNotFound = "There is no interceptor available."
    }
    
    public var interceptors: [Interceptor]
    
    private var currentIndex: Int
    private var interceptorIndexes: [String: Int] = [:]
    
    public init(
        interceptors: [Interceptor]
    ) {
        self.interceptors = interceptors
        self.currentIndex = 0
        
        for (index, interceptor) in interceptors.enumerated() {
          self.interceptorIndexes[interceptor.id] = index
        }
    }
    
    public func kickoff<Request>(
        request: Request,
        completion: @escaping (Result<Request.Data, Error>) -> Void
    ) where Request: HTTPRequest {
        assert(self.currentIndex == 0)
        
        guard let firstInterceptor = interceptors.first else {
            handleErrorAsync(
                InterceptError.interceptorNotFound,
                request: request,
                response: nil,
                completion: completion
            )
            return
        }
        
        firstInterceptor.intercept(
            request: request,
            response: nil
        )
    }
    
    public func handleErrorAsync<Request>(
        _ error: Error,
        request: Request,
        response: HTTPResponse<Request>?,
        completion: @escaping (Result<Request.Data, Error>) -> Void
    ) where Request : HTTPRequest {
        
    }
}
