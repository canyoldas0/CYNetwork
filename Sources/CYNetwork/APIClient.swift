import Foundation

typealias NetworkResponse = (data: Data, urlResponse: URLResponse)

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
        let networkResponse: NetworkResponse = try await session.data(for: request)
        
        if let httpResponse = networkResponse.urlResponse as? HTTPURLResponse {
            
            switch httpResponse.statusCode {
                
            case 200..<300:
                return try handleSuccessStatusCode(networkResponse.data)
            case 300...400:
                
            }
            
        }
        
        
//        do {
//            let decodedData = try jsonDecoder.decode(T.self, from: response.data)
//            logger.debug("Successful: \(request.url?.absoluteString ?? "")")
//            return decodedData
//        } catch {
//            logger.error("Decoding error:  \(request.url?.absoluteString ?? "") \n \(error.localizedDescription)")
//            throw error
//        }
    }
    
    private func handleSuccessStatusCode<T: Decodable>(_ data: Data) throws -> T {
        do {
            let decodedData = try jsonDecoder.decode(T.self, from: data)
            return decodedData
        } catch {
            throw NetworkError.decodingFailed
        }
    }
}


