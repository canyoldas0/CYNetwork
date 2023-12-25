import Foundation

public protocol Interceptor {
    
    var id: String { get set }

    func intercept<Request: HTTPRequest>(
        request: Request,
        response: HTTPResponse<Request>
    )
}
