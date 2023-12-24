
import Foundation

public protocol APIClientProtocol {
    
    public var interceptorHandler: InterceptorHandler { get }
    
    public func perform<T: Decodable>(_ request: URLRequest) async throws -> T
}

public class APIClient: APIClientProtocol {
    
    let interceptorHandler: InterceptorHandler
    private let baseAPI: BaseAPI
    
    init(
        interceptorHandler: InterceptorHandler,
        sessionConfiguration: URLSessionConfiguration = .default
    ) {
        self.interceptorHandler = interceptorHandler
        self.baseAPI = BaseAPI(session: sessionConfiguration)
    }
    
    func perform<T: Decodable>(_ request: URLRequest) async throws -> T {
        
        interceptorHandler
    }
}
