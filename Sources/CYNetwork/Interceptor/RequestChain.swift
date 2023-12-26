//
//  File.swift
//  
//
//  Created by Can Yoldas on 25/12/2023.
//

import Foundation

public protocol ChainErrorHandler {
    
    func handleErrorAsync<Request>(
        error: Error,
        chain: RequestChain,
        request: Request,
        response: HTTPResponse<Request>?,
        completion: @escaping (Result<Request.Data, Error>) -> Void) where Request: HTTPRequest
}

public protocol RequestChain: AnyObject {
    
    var interceptors: [Interceptor] { get set }
    var errorHandler: ChainErrorHandler? { get }
    
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
    
    func retry<Request>(
        request: Request,
        completion: @escaping (Result<Request.Data, Error>) -> Void
    ) where Request: HTTPRequest
}

public class NetworkInterceptChain: RequestChain {
    
    public enum InterceptError: String, LocalizedError {
        case interceptorNotFound = "There is no interceptor available."
    }
    
    // MARK: Public
    public var interceptors: [Interceptor]
    public var errorHandler: ChainErrorHandler?
    
    @Atomic private var isCancelled: Bool = false
    
    // MARK: Private
    private var currentIndex: Int
    private var interceptorIndexes: [String: Int] = [:]
    private var dispatchQueue: DispatchQueue
    
    public init(
        interceptors: [Interceptor],
        dispatchQueue: DispatchQueue = .main
    ) {
        self.interceptors = interceptors
        self.currentIndex = 0
        self.dispatchQueue = dispatchQueue
        
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
    
    public func retry<Request>(
        request: Request,
        completion: @escaping (Result<Request.Data, Error>) -> Void
    ) where Request : HTTPRequest {
        guard !self.isCancelled else {
            return
        }
        
        self.currentIndex = 0
        self.kickoff(
            request: request,
            completion: completion
        )
    }
    
    public func handleErrorAsync<Request>(
        _ error: Error,
        request: Request,
        response: HTTPResponse<Request>?,
        completion: @escaping (Result<Request.Data, Error>) -> Void
    ) where Request : HTTPRequest {
        guard !self.isCancelled else {
          return
        }
        
        guard let errorHandler else {
            dispatchQueue.async {
                completion(.failure(error))
            }
            return
        }
        
       // Handle error
        
    }
}
