import Foundation

typealias NetworkResponse = (data: Data, response: URLResponse)

enum LogLevel {
    case verbose
}

final public class APIClient {
    
    public init(
        session: URLSession
    ) {
        self.session = session
    }
    
    private let session: URLSession
    private let jsonDecoder = JSONDecoder()
    private let logger = AppLogger(category: "BaseAPI")
    
    public func execute<T: Decodable>(request: URLRequest) async throws -> T {
        
        logger.debug("Execute Called for path: \(request.url?.absoluteString ?? "")")
        let response: NetworkResponse = try await session.data(for: request)
        logger.debug("\(String(data: response.data, encoding: .utf8) ?? "")")
        do {
            let decodedData = try jsonDecoder.decode(T.self, from: response.data)
            logger.debug("Successful: \(request.url?.absoluteString ?? "")")
            return decodedData
        } catch {
            logger.error("Decoding error:  \(request.url?.absoluteString ?? "") \n \(error.localizedDescription)")
            throw error
        }
    }
}


