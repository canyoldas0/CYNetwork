import Foundation

open class URLSessionClient: NSObject, URLSessionDelegate, URLSessionDataDelegate {
    
    public typealias Completion = (Result<(Data, HTTPURLResponse), Error>) -> Void
    
    enum URLSessionError: Error, LocalizedError {
        case sessionInvalidated
        case noHttpResponse
        
        var errorDescription: String? {
            switch self {
            case .sessionInvalidated: "Session is invalidated."
            case .noHttpResponse: "No Http response has been received."
            }
        }
    }
    
    @Atomic private var hasBeenInvalidated: Bool = false
    @Atomic private var tasks: [Int: TaskData] = [:]
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
                          completion: @escaping Completion) -> URLSessionTask? {
        guard !self.hasBeenInvalidated else {
            completion(.failure(URLSessionError.sessionInvalidated))
            return nil
        }
        
        let task = self.session.dataTask(with: request)
        let taskData = TaskData(completionBlock: completion)
        self.$tasks.mutate { $0[task.taskIdentifier] = taskData }
        
        task.resume()
        return task
    }
    
    public func invalidate() {
        self.$hasBeenInvalidated.mutate { $0 = true }
        func cleanup() {
            self.session = nil
            self.clearAllTasks()
        }
        
        guard let session = self.session else {
            cleanup()
            return
        }
        
        session.invalidateAndCancel()
        cleanup()
    }
    
    open func clear(task identifier: Int) {
      self.$tasks.mutate { _ = $0.removeValue(forKey: identifier) }
    }
    
    open func clearAllTasks() {
        guard !self.tasks.isEmpty else {
            return
        }
        
        self.$tasks.mutate { $0.removeAll() }
    }
    
    open func urlSession(
        _ session: URLSession,
        dataTask: URLSessionDataTask,
        didReceive data: Data
    ) {
        guard dataTask.state != .canceling else {
            // Task is in the process of cancelling, don't bother handling its data.
            return
        }
        
        guard let taskData = self.tasks[dataTask.taskIdentifier] else {
            assertionFailure("No data found for task \(dataTask.taskIdentifier), cannot append received data")
            return
        }
        
        taskData.append(additionalData: data)
        
 
    }
    
    open func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: Error?
    ) {
        defer { self.clear(task: task.taskIdentifier) }
        
        guard let taskData = self.tasks[task.taskIdentifier] else {
          // This means that task is already cancelled or cleaned, time to return.
          return
        }
        
        let finalData = taskData.data
        let finalResponse = taskData.response
        
        let completion = taskData.completionBlock
        
        if let error {
            completion(.failure(error))
        } else {
            guard let finalResponse else {
                completion(.failure(URLSessionError.noHttpResponse))
                return
            }
            
            completion(.success((finalData, finalResponse)))
        }
    }
    
    open func urlSession(_ session: URLSession,
                         dataTask: URLSessionDataTask,
                         willCacheResponse proposedResponse: CachedURLResponse,
                         completionHandler: @escaping (CachedURLResponse?) -> Void) {
      completionHandler(proposedResponse)
    }
    
    open func urlSession(_ session: URLSession,
                         dataTask: URLSessionDataTask,
                         didReceive response: URLResponse,
                         completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        defer {
            completionHandler(.allow)
        }
        
        self.$tasks.mutate {
            guard let taskData = $0[dataTask.taskIdentifier] else {
                return
            }
            
            taskData.responseReceived(response: response)
        }
    }
}
