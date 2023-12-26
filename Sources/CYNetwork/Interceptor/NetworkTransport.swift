import Foundation

public protocol NetworkTransportProtocol {
    
    func send<Request>(
        request: Request,
        dispatchQueue: DispatchQueue,
        completion: @escaping (Result<Request.Data,Error>) -> Void
    ) where Request: HTTPRequest
}


public class NetworkTransporter: NetworkTransportProtocol {
    
    private let interceptors: [Interceptor]
    
    init(interceptors: [Interceptor]) {
        self.interceptors = interceptors
    }
    
    public func send<Request>(
        request: Request,
        dispatchQueue: DispatchQueue,
        completion: @escaping (Result<Request.Data,Error>) -> Void
    ) where Request: HTTPRequest {
        let chain = makeRequestChain(interceptors: interceptors)
        chain.kickoff(
            request: request,
            completion: completion
        )
    }
    
    func makeRequestChain(interceptors: [Interceptor]) -> RequestChain {
        return NetworkInterceptChain(interceptors: interceptors)
    }
}
