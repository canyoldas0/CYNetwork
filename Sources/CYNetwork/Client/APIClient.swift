
import Foundation


public protocol APIClientProtocol {
    
    // TODO: Add protocol
    var networkTransporter: NetworkTransporter { get }
    
//    func perform<T: Decodable>(_ request: URLRequest) async throws -> T
}

public class APIClient: APIClientProtocol {
    
    public private(set) var networkTransporter: NetworkTransporter
    
    public init(
        networkTransporter: NetworkTransporter,
        sessionConfiguration: URLSessionConfiguration = .default
    ) {
        self.networkTransporter = networkTransporter
    }
    
    public func perform<T: Decodable>(
        _ request: HTTPRequest<T>,
        dispatchQueue: DispatchQueue = .main,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        networkTransporter.send(
            request: request,
            dispatchQueue: dispatchQueue,
            completion: completion
        )
    }
    
    public func perform<T: Decodable>(
        _ request: HTTPRequest<T>,
        dispatchQueue: DispatchQueue = .main) async throws -> T {
            try await withCheckedThrowingContinuation { continuation in
                self.perform(
                    request,
                    dispatchQueue: dispatchQueue
                ) { result in
                    
                    switch result {
                    case .success(let success):
                        continuation.resume(returning: success)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
}

// Example Flow - Happy path
open class HTTPRequest<T: Decodable> { }

class DetailRequest: HTTPRequest<DetailResponse> {
    let id: String
    
    init(id: String) {
        self.id = id
    }
}

struct DetailResponse: Decodable { }

func fetchData() async throws {
    
    let apiClient = APIClient(networkTransporter: .init(interceptors: []))
    
    let request = DetailRequest(id: "id")
    
    let data = try await apiClient.perform(request)
}
