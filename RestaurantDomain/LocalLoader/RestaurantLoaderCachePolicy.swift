//
//  RestaurantLoaderCachePolicy.swift
//  RestaurantDomain
//
//  Created by Guilherme Prata Costa on 22/06/23.
//

import Foundation


final class RestaurantLoaderCachePolicy: CachePolicy {
    private let maxAge = 1
    
    func validate(_ timestamp: Date, with currentDate: Date) -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        guard let maxAge = calendar.date(byAdding: .day, value: maxAge, to: timestamp) else { return false}
        
        return currentDate < maxAge
    }
}
