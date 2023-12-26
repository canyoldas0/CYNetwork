import Foundation

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
            chain: self,
            request: request,
            response: nil,
            completion: completion
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
        
        // Handle error if there is an error handler assigned.
        guard let errorHandler else {
            // if not return error directly.
            dispatchQueue.async {
                completion(.failure(error))
            }
            return
        }
        
        let dispatchQueue = self.dispatchQueue
        errorHandler.handleError(
            error: error,
            chain: self,
            request: request,
            response: response
        ) { result in
            dispatchQueue.async {
              completion(result)
            }
        }
    }
    
    public func proceed<Request>(
        interceptorIndex: Int,
        request: Request,
        response: HTTPResponse<Request>?,
        completion: @escaping (Result<Request.Data, Error>) -> Void
    ) where Request : HTTPRequest {
        guard !self.isCancelled else {
          return
        }
        
        if self.interceptors.indices.contains(interceptorIndex) {
            self.currentIndex = interceptorIndex
            
            let currentInterceptor = interceptors[currentIndex]
            
            currentInterceptor.intercept(
                chain: self,
                request: request,
                response: response,
                completion: completion
            )
        }
    }
    
    public func returnValue<Request>(
        for request: Request,
        value: Request.Data,
        completion: @escaping (Result<Request.Data, Error>) -> Void
    ) where Request : HTTPRequest {
        guard !self.isCancelled else {
          return
        }
        
        self.dispatchQueue.async {
            completion(.success(value))
        }
    }
}
