import Foundation

public protocol Interceptor {
    func intercept(request: inout URLRequest) async throws
}

public class InterceptorHandler {
    
    private let interceptors: [Interceptor]
    
    init(
        interceptors: [Interceptor]
    ) {
        self.interceptors = interceptors
    }
    
    func interceptChain(request: inout URLRequest) async throws {
        for interceptor in interceptors {
            try await interceptor.intercept(request: &request)
        }
    }
}
