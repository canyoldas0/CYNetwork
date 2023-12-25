import Foundation

public class TokenProviderInterceptor: Interceptor {

    public var id: String = "token_provider_interceptor"
   
    public func intercept<Request: HTTPRequest>(request: Request, response: HTTPResponse<Request>) {
        
    }
}
