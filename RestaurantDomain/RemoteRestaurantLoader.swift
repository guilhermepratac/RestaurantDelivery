//
//  RemoteRestaurantLoader.swift
//  RestaurantDomain
//
//  Created by Guilherme Prata Costa on 16/02/23.
//

import Foundation


final class RemoteRestaurantLoader {
    
    let url: URL
    
    init(url: URL) {
        self.url = url
    }
    
    func load() {
        NetworkClient.shared.request(from: url)
    }
}
