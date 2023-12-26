import Foundation

public class NetworkFetchInterceptor: Interceptor {
    
    public var id: String = UUID().uuidString
    
    let client: URLSessionClient
    
    public init(client: URLSessionClient) {
        self.client = client
    }
    
    public func intercept<Request>(
        chain: RequestChain,
        request: HTTPRequest<Request>,
        response: HTTPResponse<Request>?,
        completion: @escaping (Result<Request.Data, Error>) -> Void
    ) where Request : Requestable {
        
    }
}
