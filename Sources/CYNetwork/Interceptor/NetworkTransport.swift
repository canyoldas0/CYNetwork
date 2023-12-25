import Foundation

public protocol NetworkTransportProtocol {
    
    func send<T: Decodable>() async throws -> T
}


public class NetworkTransporter: NetworkTransportProtocol {
    
    private let interceptors: [Interceptor]
    
    init(interceptors: [Interceptor]) {
        self.interceptors = interceptors
    }
    
    func kickoffChain(request: inout URLRequest) {
        
        guard let firstInterceptor = interceptors.first else {
            // TODO: Error handling.
            return
        }
        
        
    }
    
    public func send<T: Decodable>() async throws -> T {
        
        let chain = makeRequestChain()
        
        
    }
    
    func makeRequestChain() -> RequestChain {
        
    }
}
