import Foundation

public protocol HTTPRequest: Encodable {
    associatedtype Data: Decodable
    
    func toUrlRequest() throws -> URLRequest
}
