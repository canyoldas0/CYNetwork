import Foundation

public protocol Interceptor {
    
    var id: String { get set }

    func intercept<Request>(
        chain: RequestChain,
        request: Request,
        response: HTTPResponse<Request>?,
        completion: @escaping (Result<Request.Data, Error>) -> Void
    ) where Request: HTTPRequest
}

public protocol Cancellable {
    func cancel()
}
