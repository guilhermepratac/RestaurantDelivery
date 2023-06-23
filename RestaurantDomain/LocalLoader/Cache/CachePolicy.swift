//
//  CachePolicy.swift
//  RestaurantDomain
//
//  Created by Guilherme Prata Costa on 22/06/23.
//

import Foundation


protocol CachePolicy {
    func validate(_ timestamp: Date, with currentDate: Date) -> Bool
}
