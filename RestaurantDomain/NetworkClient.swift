import Foundation

enum NetworkState {
    case sucess
    case error(Error)
}
protocol NetworkClient {
    func request(from url: URL, completion: @escaping (NetworkState) -> Void )
}
