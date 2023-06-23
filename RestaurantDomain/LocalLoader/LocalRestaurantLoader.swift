//
//  LocalRestaurantLoader.swift
//  RestaurantDomain
//
//  Created by Guilherme Prata Costa on 21/06/23.
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

final class LocalRestaurantLoader {
    
    let cache: CacheClient
    let cachePolicy: CachePolicy
    let currentDate: () -> Date
    
    /*
     ## Controlando nosso tempo de cache nos testes de forma mais eficiente
     O Date() não é uma função pura porque toda vez que você cria uma instância de Data, ela tem um valor diferente - a data/hora atual, em vez de permitir que o
     LocalRestaurantLoader crie a data atual diretamente, podemos mover essa responsabilidade para fora do escopo da classe e injetá-la como uma dependência. Então, podemos
     facilmente controlar a data/hora atual durante os testes.
     */
    init(cache: CacheClient, cachePolicy: CachePolicy = RestaurantLoaderCachePolicy(), currentDate: @escaping () -> Date) {
        self.cache = cache
        self.cachePolicy = cachePolicy
        self.currentDate = currentDate
    }
    
    func save(_ items: [RestaurantItem], completion: @escaping (Error?) -> Void) {
        cache.delete { [weak self] error in
            guard let self else { return }
            guard let error else {
                return self.saveOnCache(items, completion: completion)
            }
            completion(error)
        }
    }
    
    private func saveOnCache(_ items: [RestaurantItem], completion: @escaping (Error?) -> Void) {
        cache.save(items, timestamp: currentDate()) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
    
    public func validateCache() {
        cache.load { [weak self] state in
            guard let self = self else { return }
            switch state {
            case let .sucess(_, timestamp) where !self.cachePolicy.validate(timestamp, with: self.currentDate()):
                self.cache.delete{ _ in }
            case .failure:
                self.cache.delete{ _ in }
            default: break
            }
        }
    }
}

extension LocalRestaurantLoader: RestaurantLoader {
    func load(completion: @escaping (Result<[RestaurantItem], RestaurantResultError>) -> Void) {
        cache.load { [weak self] state in
            guard let self = self else { return }
            switch state {
            case let .sucess(items, timestamp) where self.cachePolicy.validate(timestamp, with: self.currentDate()):
                completion(.success(items))
            case .sucess, .empty:
                completion(.success([]))
            case .failure:
                completion(.failure(.invalidData))
            }
        }
    }
}
