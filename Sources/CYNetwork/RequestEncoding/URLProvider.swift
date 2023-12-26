import Foundation

public protocol Requestable: Encodable {
    func request() throws -> URLRequest
}

public protocol URLRequestProtocol {
    static func returnUrlRequest<T: Encodable>(
        method: HTTPMethod,
        baseUrl: String,
        path: String?,
        data: T?) throws -> URLRequest
}

public class ApiServiceProvider: URLRequestProtocol {

    public static func returnUrlRequest<T: Encodable>(
        method: HTTPMethod = .get,
        baseUrl: String,
        path: String?,
        data: T) throws -> URLRequest {
        
        guard var url = URL(string: baseUrl) else { throw NetworkError.missingURL }
        
        if let path = path {
            url = url.appendingPathComponent(path)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.headers = headers()
        
            try configureEncoding(
                method: method,
                data: data,
                request: &request
            )
        
        return request
    }
    
    private static func configureEncoding<T: Encodable>(
        method: HTTPMethod,
        data: T?,
        request: inout URLRequest
    ) throws {
        let params = data?.asDictionary()
        
        switch method {
        case .post, .put:
            try ParameterEncoding.jsonEncoding.encode(urlRequest: &request, parameters: params)
        case .get:
            try ParameterEncoding.urlEncoding.encode(urlRequest: &request, parameters: params)
        default:
            try ParameterEncoding.urlEncoding.encode(urlRequest: &request, parameters: params)
        }
    }
    
  
    
    private static func headers() -> HTTPHeaders {
        var httpHeaders = HTTPHeaders()
        httpHeaders.add(HTTPHeader(name: HTTPHeaderFields.contentType.value.0, value: HTTPHeaderFields.contentType.value.1))
        return httpHeaders
    }
}
