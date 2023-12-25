import Foundation

public protocol Requestable: Encodable {
    func request() throws -> URLRequest
}

public protocol URLRequestProtocol {
    func returnUrlRequest() throws -> URLRequest
}

class ApiServiceProvider<T: Encodable>: URLRequestProtocol {
    
    private var method: HTTPMethod
    private var baseUrl: String
    private var path: String?
    private var data: T?
    
    public init(
        method: HTTPMethod = .get,
        baseUrl: String,
        path: String? = nil,
        data: T? = nil
    ) {
        
        self.method = method
        self.baseUrl = baseUrl
        self.path = path
        self.data = data
    }
    
    func returnUrlRequest() throws -> URLRequest {
        
        guard var url = URL(string: baseUrl) else { throw NetworkError.missingURL }
        
        if let path = path {
            url = url.appendingPathComponent(path)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.headers = headers
        
        try configureEncoding(request: &request)
        
        return request
    }
    
    private func configureEncoding(request: inout URLRequest) throws {
        switch method {
        case .post, .put:
            try ParameterEncoding.jsonEncoding.encode(urlRequest: &request, parameters: params)
        case .get:
            try ParameterEncoding.urlEncoding.encode(urlRequest: &request, parameters: params)
        default:
            try ParameterEncoding.urlEncoding.encode(urlRequest: &request, parameters: params)
        }
    }
    
    private var params: Parameters? {
        return data.asDictionary()
    }
    
    private var headers: HTTPHeaders {
        var httpHeaders = HTTPHeaders()
        httpHeaders.add(HTTPHeader(name: HTTPHeaderFields.contentType.value.0, value: HTTPHeaderFields.contentType.value.1))
        return httpHeaders
    }
}
