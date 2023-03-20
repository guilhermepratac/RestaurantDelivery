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
    typealias RemoteRestaurantResult = Result<[RestaurantItem], RemoteRestaurantLoader.Error>

    
    enum Error: Swift.Error {
        case connectivitiy
        case invalidData
    }
    
    init(url: URL, networkClient: NetworkClient) {
        self.url = url
        self.networkClient = networkClient
    }
        
    func load(completion: @escaping (RemoteRestaurantResult) -> Void) {
        networkClient.request(from: url) { result in
            switch result {
            case let .success(data, _):
                guard let json = try? JSONDecoder().decode(RestaurantRoot.self, from: data) else {
                    return completion(.failure(.invalidData))
                }
                
                completion(.success(json.items))
                
            case .failure : completion(.failure(.connectivitiy))
            }
            
        }
    }
}
