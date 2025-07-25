import Foundation

open class HTTPOperation<Request: Requestable> {
    
    public struct HTTPProperties {
        let url: URL
        let httpMethod: HTTPMethod
        var additionalHeaders: [String: String]
        var additionalQueryItems: [URLQueryItem]
        let data: (any Encodable)?
        
        public var requestName: String {
            String(describing: Request.self)
        }
        
        public init(
            url: URL,
            httpMethod: HTTPMethod,
            additionalHeaders: [String : String] = [:],
            additionalQueryItems: [URLQueryItem] = [],
            data: (any Encodable)? = nil
        ) {
            self.url = url
            self.httpMethod = httpMethod
            self.additionalHeaders = additionalHeaders
            self.additionalQueryItems = additionalQueryItems
            self.data = data
        }
    }
    
    public var rawRequest: Request
    public var properties: HTTPProperties
    public let cachePolicy: CachePolicy
    
    public init(
        request: Request,
        cachePolicy: CachePolicy
    ) {
        self.rawRequest = request
        self.properties = request.httpProperties()
        self.cachePolicy = cachePolicy
    }
    
    public func addHeader(key: String, val: String) {
        properties.additionalHeaders[key] = val
    }
    
    public func addQueryItem(key: String, val: String) {
        properties.additionalQueryItems.append(.init(name: key, value: val))
    }
}

public protocol Requestable: Encodable {
    associatedtype Data: Decodable

    nonisolated func httpProperties() -> HTTPOperation<Self>.HTTPProperties
}
