//
//  RemoteRestaurantLoader.swift
//  RestaurantDomain
//
//  Created by Guilherme Prata Costa on 16/02/23.
//

import Foundation

struct RestaurantRoot: Decodable {
    let items: [RestaurantItem]
}

struct RestaurantItem: Decodable, Equatable {
    let id: UUID
    let name: String
    let location: String
    let distance: Float
    let ratings: Int
    let parasols: Int
}

final class RemoteRestaurantLoader {
    
    let url: URL
    let networkClient: NetworkClient
    private let okResponse: Int = 200
    typealias RemoteRestaurantResult = Result<[RestaurantItem], RemoteRestaurantLoader.Error>

    
    enum Error: Swift.Error {
        case connectivitiy
        case invalidData
    }
    
    init(url: URL, networkClient: NetworkClient) {
        self.url = url
        self.networkClient = networkClient
    }
    
    func jsonParse(_ data: Data, response: HTTPURLResponse) -> RemoteRestaurantResult {
        guard let json = try? JSONDecoder().decode(RestaurantRoot.self, from: data), response.statusCode == okResponse else {
            return .failure(.invalidData)
        }
        
        return .success(json.items)
    }
        
    func load(completion: @escaping (RemoteRestaurantResult) -> Void) {
        networkClient.request(from: url) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success((data, response)): completion(self.jsonParse(data, response: response))
            case .failure : completion(.failure(.connectivitiy))
            }
            
        }
    }
}
