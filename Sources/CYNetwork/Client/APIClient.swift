
import Foundation

public protocol APIClientProtocol {
    
    var networkTransporter: NetworkTransporter { get }
    
    func perform<T: Decodable>(_ request: URLRequest) async throws -> T
}

public class APIClient: APIClientProtocol {
    
    public private(set) var networkTransporter: NetworkTransporter
    
    public init(
        networkTransporter: NetworkTransporter,
        sessionConfiguration: URLSessionConfiguration = .default
    ) {
        self.networkTransporter = networkTransporter
    }
    
    public func perform<T: Decodable>(_ request: URLRequest, resultHandler: @escaping (Result<T,Error>) -> Void)  {
        var interceptedRequest = request
        try await networkTransporter.kickoffChain(request: &interceptedRequest)
    }
}
