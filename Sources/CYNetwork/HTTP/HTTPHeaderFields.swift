
import Foundation

public enum HTTPHeaderFields {
    
    case contentType
    
    var value: (String, String) {
        switch self {
        case .contentType:
            return ("Content-Type", "application/json; charset=utf-8")
        }
    }

}
