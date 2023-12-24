import Foundation

public protocol Interceptor {
    
    var id: String { get set }

    func intercept(request: inout URLRequest)
}

public class NetworkTransporter {
    
    private let interceptors: [Interceptor]
    
    init(
        interceptors: [Interceptor]
    ) {
        self.interceptors = interceptors
    }
    
    func kickoffChain(
        request: inout URLRequest) {
        for interceptor in interceptors {
            interceptor.intercept(request: &request)
        }
    }
}
