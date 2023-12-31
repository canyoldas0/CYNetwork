import Foundation

open class HTTPResponse<Request: Requestable> {
    
    var httpResponse: HTTPURLResponse
    var rawData: Data
    var parsedData: Request.Data?
    
    init(
        httpResponse: HTTPURLResponse,
        rawData: Data
    ) {
        self.httpResponse = httpResponse
        self.rawData = rawData
    }
}
