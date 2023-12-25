import Foundation

public protocol NetworkTransportProtocol {
    
//    func send(request: URLRequest)
}


public class NetworkTransporter: NetworkTransportProtocol {
    
    private let interceptors: [Interceptor]
    
    init(interceptors: [Interceptor]) {
        self.interceptors = interceptors
    }
    
    public func send<T: Decodable>(
        request: HTTPRequest<T>,
        dispatchQueue: DispatchQueue,
        completion: @escaping (Result<T,Error>) -> Void
    ) {
        let chain = makeRequestChain(interceptors: interceptors)
        
//        chain.kickoff(request: request)
    }
    
    func makeRequestChain(interceptors: [Interceptor]) -> RequestChain {
        return NetworkInterceptChain(interceptors: interceptors)
    }
}
