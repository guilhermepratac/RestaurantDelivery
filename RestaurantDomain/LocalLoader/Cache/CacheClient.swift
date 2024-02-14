//
//  CacheClient.swift
//  RestaurantDomain
//
//  Created by Guilherme Prata Costa on 22/06/23.
//

import Foundation

public enum LoadResultState {
    case empty
    case sucess(_ items: [RestaurantItem], timestamp: Date)
    case failure(Error)
}

public protocol CacheClient {
    typealias SaveResult = (Error?) -> Void
    typealias DeleteResult = (Error?) -> Void
    typealias LoadResult = (LoadResultState) -> Void
    
    func save(_ items: [RestaurantItem], timestamp: Date, completion: @escaping SaveResult)
    func delete(completion: @escaping DeleteResult)
    func load(completion: @escaping LoadResult)
}

final class CacheService: CacheClient {
    private struct Cache: Codable {
        let items: [RestaurantItem]
        let timestamp: Date
    }
    
    private let managerUrl: URL
    
    init(managerUrl: URL) {
        self.managerUrl = managerUrl
    }
    
    func save(_ items: [RestaurantItem], timestamp: Date, completion: @escaping SaveResult) {
        do {
            let cache = Cache(items: items, timestamp: timestamp)
            
            let encoder = JSONEncoder()
            let encoded = try encoder.encode(cache)
            try encoded.write(to: managerUrl)
            
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    func delete(completion: @escaping DeleteResult) {
        guard FileManager.default.fileExists(atPath: managerUrl.path) else {
            return completion(nil)
        }
        
        do {
            try FileManager.default.removeItem(at: managerUrl)
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    func load(completion: @escaping LoadResult) {
        guard let data = try? Data(contentsOf: managerUrl) else {
            return completion(.empty)
        }
        
        do {
            let decoder = JSONDecoder()
            let cache = try decoder.decode(Cache.self, from: data)
            
            completion(.sucess(cache.items, timestamp: cache.timestamp))
        } catch {
            completion(.failure(error))
        }
    }
    
    
}
