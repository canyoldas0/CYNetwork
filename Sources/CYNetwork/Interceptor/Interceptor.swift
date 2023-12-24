import Foundation

public protocol Interceptor {
    func intercept(request: inout URLRequest) async throws
}
