
import Foundation

public protocol APIClientProtocol {
    
    var interceptorHandler: InterceptorHandler { get }
    
    func perform<T: Decodable>(_ request: URLRequest) async throws -> T
}

public class APIClient: APIClientProtocol {
    
    public private(set) var interceptorHandler: InterceptorHandler
    private let baseAPI: BaseAPI
    
    public init(
        interceptorHandler: InterceptorHandler,
        sessionConfiguration: URLSessionConfiguration = .default
    ) {
        self.interceptorHandler = interceptorHandler
        self.baseAPI = BaseAPI(configuration: sessionConfiguration)
    }
    
    public func perform<T: Decodable>(_ request: URLRequest) async throws -> T {
        var interceptedRequest = request
        try await interceptorHandler.interceptChain(request: &interceptedRequest)
        
        return try await baseAPI.execute(request: interceptedRequest)
    }
}
