import Foundation

public protocol NetworkTransportProtocol {
    
    func send<Request>(
        request: Request,
        dispatchQueue: DispatchQueue,
        completion: @escaping (Result<Request.Data,Error>) -> Void
    ) where Request: Requestable
}


open class DefaultRequestChainNetworkTransport: NetworkTransportProtocol {
    
    let interceptorProvider: InterceptorProvider
    
    public init(interceptorProvider: InterceptorProvider) {
        self.interceptorProvider = interceptorProvider
    }
    
    public func send<Request>(
        request: Request,
        dispatchQueue: DispatchQueue,
        completion: @escaping (Result<Request.Data,Error>) -> Void
    ) where Request: Requestable {
        let chain = makeRequestChain(for: request)
        
        let request = HTTPRequest(request: request, additionalHeaders: [:])
        chain.kickoff(
            request: request,
            completion: completion
        )
    }
    
    open func makeRequestChain<Request>(for request: Request) -> RequestChain where Request: Requestable {
        return NetworkInterceptChain(
            interceptors: interceptorProvider.interceptors(for: request),
            errorHandler: interceptorProvider.additionalErrorHandler(for: request)
        )
    }
}
