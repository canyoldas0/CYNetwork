import Foundation

public protocol NetworkTransportProtocol {
    
    func send<T: Decodable>(
        request: URLRequest) async throws -> T
}


public class NetworkTransporter: NetworkTransportProtocol {
    
    private let interceptors: [Interceptor]
    
    init(interceptors: [Interceptor]) {
        self.interceptors = interceptors
    }
    
    public func send<T: Decodable>(
        request: URLRequest) async throws -> T {
        let chain = makeRequestChain(interceptors: interceptors)
        
        return try await chain.kickoff(request: request)
    }
    
    func makeRequestChain(interceptors: [Interceptor]) -> RequestChain {
        return NetworkInterceptChain(interceptors: interceptors)
    }
}
