//
//  RestaurantLoader.swift
//  RestaurantDomain
//
//  Created by Guilherme Prata Costa on 21/06/23.
//

import Foundation

public enum RestaurantResultError: Swift.Error {
    case connectivitiy
    case invalidData
}

public protocol RestaurantLoader {
    typealias RestaurantResult = Result<[RestaurantItem], RestaurantResultError>
    func load(completion: @escaping (RestaurantLoader.RestaurantResult) -> Void)
}
