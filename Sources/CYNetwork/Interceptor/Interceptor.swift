import Foundation

public protocol Interceptor {
    
    var id: String { get set }

    func intercept<T: Decodable>(request: inout URLRequest) async throws -> T
}
