import Foundation

public protocol Interceptor {
    
    var id: String { get set }

    func intercept<Request: HTTPRequest>(
        chain: RequestChain,
        request: Request,
        response: HTTPResponse<Request>?
    )
}
