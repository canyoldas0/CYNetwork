
import Foundation


public class APIClient {
    
    public private(set) var networkTransporter: NetworkTransportProtocol
    
    public init(
        networkTransporter: NetworkTransportProtocol
    ) {
        self.networkTransporter = networkTransporter
    }
    
    convenience init() {
        let provider = DefaultInterceptorProvider(client: URLSessionClient(sessionConfiguration: .default))
        let transporter = DefaultRquestChainNetworkTransport(interceptorProvider: provider)
        
        self.init(networkTransporter: transporter)
    }
    
    public func perform<Request: Requestable>(
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
    
    public func perform<Request: Requestable>(
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

public extension APIClient {
    static let shared = APIClient()
}

struct DetailRequest: Requestable {
    let id: String
 
    struct Data: Decodable {
        let name: String
    }
    
    func toUrlRequest() throws -> URLRequest {
        try ApiServiceProvider.returnUrlRequest(
            baseUrl: "",
            path: nil,
            data: self
        )
    }
}

func fetchData() async throws {
    let request = DetailRequest(id: "id")
    
    let data = try await APIClient.shared.perform(request)
}

// TODO: Add Property wrappers, some properties of the Requestable doesn't need to be in query, exclude them
/// For example
/// ```
/// struct Request: Requestable {
/// @NonQueryItem var id: String
/// var cityName: String
/// }
///
/// let request = Request(id: 5, cityName: "Amsterdam")
///
/// example url: `dummyApi.com/v2/id/5?cityName=Amsterdam`
