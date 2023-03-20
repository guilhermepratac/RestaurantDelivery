import Foundation

final class NetworkClient {
    
    static let shared: NetworkClient = NetworkClient()
    private(set) var urlRequest: URL?
    
    private init() {}
    
    func request(from url: URL) {
        urlRequest = url
    }
}
