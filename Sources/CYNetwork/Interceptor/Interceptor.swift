import Foundation

public protocol Interceptor {
    
    var id: String { get set }

    func intercept(request: inout URLRequest) async throws
}

public class NetworkTransporter {
    
    private let interceptors: [Interceptor]
    
    init(
        interceptors: [Interceptor]
    ) {
        self.interceptors = interceptors
    }
    
    func kickoffChain(
        request: inout URLRequest) async throws {
        for interceptor in interceptors {
            try await interceptor.intercept(request: &request)
        }
    }
}
