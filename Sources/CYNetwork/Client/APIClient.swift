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
        let transporter = DefaultRequestChainNetworkTransport(interceptorProvider: provider)
        
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
