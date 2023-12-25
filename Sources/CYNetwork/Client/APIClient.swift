
import Foundation


public protocol APIClientProtocol {
    
    var networkTransporter: NetworkTransportProtocol { get }
    
//    func perform<T: Decodable>(_ request: URLRequest) async throws -> T
}

public class APIClient: APIClientProtocol {
    
    public private(set) var networkTransporter: NetworkTransportProtocol
    
    public init(
        networkTransporter: NetworkTransporter,
        sessionConfiguration: URLSessionConfiguration = .default
    ) {
        self.networkTransporter = networkTransporter
    }
    
    public func perform(_ request: URLRequest) {
        networkTransporter.send(request: request)
    }
}
