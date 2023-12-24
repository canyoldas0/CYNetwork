import Foundation

public protocol Interceptor {
    func intercept(request: inout URLRequest) async throws
}

public class InterceptorHandler {
    
    private let callbackQueue: DispatchQueue
    private let interceptors: [Interceptor]
    
    init(
        interceptors: [Interceptor],
        callbackQueue: DispatchQueue = .main
    ) {
        self.callbackQueue = callbackQueue
        self.interceptors = interceptors
    }
    
    
}
