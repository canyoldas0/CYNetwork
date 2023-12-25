import Foundation

public protocol Interceptor {
    
    var id: String { get set }

    func intercept(request: inout URLRequest)
}
