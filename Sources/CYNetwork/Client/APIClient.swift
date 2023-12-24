
import Foundation

public protocol APIClientProtocol {
    
    var networkTransporter: NetworkTransporter { get }
    
    func perform<T: Decodable>(_ request: URLRequest) async throws -> T
}

public class APIClient: APIClientProtocol {
    
    public private(set) var networkTransporter: NetworkTransporter
    private let baseAPI: BaseAPI
    
    public init(
        networkTransporter: NetworkTransporter,
        sessionConfiguration: URLSessionConfiguration = .default
    ) {
        self.networkTransporter = networkTransporter
        self.baseAPI = BaseAPI(configuration: sessionConfiguration)
    }
    
    public func perform<T: Decodable>(_ request: URLRequest) async throws -> T {
        var interceptedRequest = request
        try await networkTransporter.kickoffChain(request: &interceptedRequest)
        
        return try await baseAPI.execute(request: interceptedRequest)
    }
}
