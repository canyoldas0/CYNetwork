
import Foundation

open class DefaultInterceptorProvider: InterceptorProvider {
    
    let client: URLSessionClient
    
    public init(client: URLSessionClient) {
        self.client = client
    }
    
    open func interceptors<Request>(
        for request: Request
    ) -> [Interceptor] where Request : Requestable {
        [
            MaxRetryInterceptor(maxRetry: 3),
            NetworkFetchInterceptor(client: self.client),
            JSONDecodingInterceptor()
        ]
    }
}
