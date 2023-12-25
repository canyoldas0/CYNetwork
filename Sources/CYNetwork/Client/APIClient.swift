
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
    
    public func perform<Request: HTTPRequest>(
        _ request: Request,
        dispatchQueue: DispatchQueue = .main,
        completion: @escaping (Result<Request.Data, Error>) -> Void
    ) {
        networkTransporter.send(
            request: request,
            dispatchQueue: dispatchQueue,
            completion: completion
        )
    }
    
    public func perform<Request: HTTPRequest>(
        _ request: Request,
        dispatchQueue: DispatchQueue = .main) async throws -> Request.Data {
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

public protocol HTTPRequest: Encodable {
    associatedtype Data: Decodable
}

open class HTTPResponse<Request: HTTPRequest> {
    
    var httpResponse: HTTPURLResponse
    var rawData: Data
    var parsedData: Request.Data?
    
    init(
        httpResponse: HTTPURLResponse,
        rawData: Data
    ) {
        self.httpResponse = httpResponse
        self.rawData = rawData
    }
}

struct DetailRequest: HTTPRequest {
    let id: String
 
    struct Data: Decodable {
        let name: String
    }
}


func fetchData() async throws {
    
    let apiClient = APIClient(networkTransporter: .init(interceptors: []))
    
    let request = DetailRequest(id: "id")
    
    let data = try await apiClient.perform(request)
}
