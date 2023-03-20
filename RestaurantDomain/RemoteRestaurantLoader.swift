//
//  RemoteRestaurantLoader.swift
//  RestaurantDomain
//
//  Created by Guilherme Prata Costa on 16/02/23.
//

import Foundation


final class RemoteRestaurantLoader {
    
    let url: URL
    let networkClient: NetworkClient
    
    enum Error: Swift.Error {
        case connectivitiy
        case invalidData
    }
    
    init(url: URL, networkClient: NetworkClient) {
        self.url = url
        self.networkClient = networkClient
    }
    
    func load(completion: @escaping (RemoteRestaurantLoader.Error) -> Void) {
        networkClient.request(from: url) { state in
            switch state {
            case .sucess: completion(.invalidData)
            case .error : completion(.connectivitiy)
            }
            
        }
    }
}
