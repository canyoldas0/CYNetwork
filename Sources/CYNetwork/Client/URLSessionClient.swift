import Foundation

open class URLSessionClient: NSObject, URLSessionDelegate {
    
    public typealias RawCompletion = (Data?, HTTPURLResponse?, Error?) -> Void
    public typealias Completion = (Result<(Data, HTTPURLResponse), Error>) -> Void
    
    enum URLSessionError: Error, LocalizedError {
        case sessionInvalidated
        
        var errorDescription: String? {
            switch self {
            case .sessionInvalidated: "Session is invalidated."
            }
        }
    }
    
    @Atomic private var hasBeenInvalidated: Bool = false
    open private(set) var session: URLSession!

    public init(
        sessionConfiguration: URLSessionConfiguration,
        callbackQueue: OperationQueue? = .main
    ) {
        super.init()
    
        self.session = URLSession(
            configuration: sessionConfiguration,
            delegate: self,
            delegateQueue: callbackQueue
        )
    }
    
    @discardableResult
    open func sendRequest(_ request: URLRequest,
                          rawTaskCompletionHandler: RawCompletion? = nil,
                          completion: @escaping Completion) -> URLSessionTask? {
        guard self.hasBeenInvalidated else {
            completion(.failure(URLSessionError.sessionInvalidated))
            return nil
        }
        
        let task = self.session.dataTask(with: request)
        // TODO: create taskData, and store completion
        task.resume()
        return task
    }
}
