//
//  CacheClient.swift
//  RestaurantDomain
//
//  Created by Guilherme Prata Costa on 22/06/23.
//

import Foundation

public enum LoadResultSate {
    case empty
    case sucess(_ items: [RestaurantItem], timestamp: Date)
    case failure(Error)
}

public protocol CacheClient {
    typealias SaveResult = (Error?) -> Void
    typealias DeleteResult = (Error?) -> Void
    typealias LoadResult = (LoadResultSate) -> Void
    
    func save(_ items: [RestaurantItem], timestamp: Date, completion: @escaping SaveResult)
    func delete(completion: @escaping DeleteResult)
    func load(completion: @escaping LoadResult)
}
