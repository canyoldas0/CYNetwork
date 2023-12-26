
import Foundation

open class DefaultInterceptorProvider: InterceptorProvider {
    
    open func interceptors<Request>(
        for request: Request
    ) -> [Interceptor] where Request : Requestable {
        []
    }
}
