import Foundation

open class HTTPRequest<Request: Requestable> {
//    associatedtype Request: Requestable
    
    open var additionalHeaders: [String: String]
    public var rawRequest: Request
    
    public init(
        request: Request,
        additionalHeaders: [String : String]
    ) {
        self.rawRequest = request
        self.additionalHeaders = additionalHeaders
    }
    
    func toUrlRequest() throws -> URLRequest {
        var request = try rawRequest.toUrlRequest()
        
        for (fieldName, value) in additionalHeaders {
          request.addValue(value, forHTTPHeaderField: fieldName)
        }
        
        return request
    }
}

public protocol Requestable: Encodable {
    associatedtype Data: Decodable
    
    func toUrlRequest() throws -> URLRequest
}
