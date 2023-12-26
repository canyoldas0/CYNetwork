import Foundation

public protocol RequestChain: AnyObject {
    
    var interceptors: [Interceptor] { get set }
    var errorHandler: ChainErrorHandler? { get }
    
    func kickoff<Request>(
        request: Request,
        completion: @escaping (Result<Request.Data, Error>) -> Void
    ) where Request: HTTPRequest
    
    func handleErrorAsync<Request>(
      _ error: Error,
      request: Request,
      response: HTTPResponse<Request>?,
      completion: @escaping (Result<Request.Data, Error>) -> Void
    ) where Request : HTTPRequest
    
    func retry<Request>(
        request: Request,
        completion: @escaping (Result<Request.Data, Error>) -> Void
    ) where Request: HTTPRequest
}
