import Foundation

public protocol NetworkTransportProtocol {
    
    func send<Request>(
        request: Request,
        dispatchQueue: DispatchQueue,
        completion: @escaping (Result<Request.Data,Error>) -> Void
    ) where Request: Requestable
}


open class NetworkTransporter: NetworkTransportProtocol {
    
    private let interceptors: [Interceptor]
    
    init(interceptors: [Interceptor]) {
        self.interceptors = interceptors
    }
    
    public func send<Request>(
        request: Request,
        dispatchQueue: DispatchQueue,
        completion: @escaping (Result<Request.Data,Error>) -> Void
    ) where Request: Requestable {
        let chain = makeRequestChain(interceptors: interceptors)
        
        let request = HTTPRequest(request: request, additionalHeaders: [:])
        chain.kickoff(
            request: request,
            completion: completion
        )
    }
    
    open func makeRequestChain(interceptors: [Interceptor]) -> RequestChain {
        return NetworkInterceptChain(interceptors: interceptors)
    }
}
