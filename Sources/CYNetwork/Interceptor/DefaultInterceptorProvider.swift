import Foundation

public final class DefaultInterceptorProvider: InterceptorProvider {
    nonisolated let client: URLSessionClient

    public init(client: URLSessionClient) {
        self.client = client
    }
    
    public func interceptors<Request: Requestable>(for operation: HTTPOperation<Request>) -> [Interceptor] {
        [
            MaxRetryInterceptor(maxRetry: 3),
            NetworkFetchInterceptor(client: client),
            JSONDecodingInterceptor()
        ]
    }
}
