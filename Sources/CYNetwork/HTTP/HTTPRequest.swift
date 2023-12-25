import Foundation

public protocol HTTPRequest: Encodable {
    associatedtype Data: Decodable
}
