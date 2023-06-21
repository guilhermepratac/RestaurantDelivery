//
//  LocalRestaurantLoader.swift
//  RestaurantDomain
//
//  Created by Guilherme Prata Costa on 21/06/23.
//

import Foundation

/*
 ### Salvar lista de restaurantes
 
 #### Dados (Entrada):
 - Listagem de restaurantes;
 
 #### Curso primário (caminho feliz):
 1. Execute o comando "Salvar listagem de restaurantes" com os dados acima.
 2. O sistema deleta o cache antigo.
 3. O sistema codifica a lista de restaurantes.
 4. O sistema marca a hora do novo cache.
 5. O sistema salva o cache com novos dados.
 6. O sistema envia uma mensagem de sucesso.
 
 #### Caso de erro (caminho triste):
 1. O sistema envia uma mensagem de erro.
 
 #### Caso de erro ao salvar (caminho triste):
 1. O sistema envia uma mensagem de erro.
 
 */

protocol CacheClient {
    typealias SaveResult = (Error?) -> Void
    typealias DeleteResult = (Error?) -> Void
    typealias LoadResult = (Error?) -> Void
    
    func save(_ items: [RestaurantItem], timestamp: Date, completion: @escaping SaveResult)
    func delete(completion: @escaping DeleteResult)
    func load(completion: @escaping LoadResult)
}

final class LocalRestaurantLoader {
    
    let cache: CacheClient
    let currentDate: () -> Date
    
    /*
     ## Controlando nosso tempo de cache nos testes de forma mais eficiente
     O Date() não é uma função pura porque toda vez que você cria uma instância de Data, ela tem um valor diferente - a data/hora atual, em vez de permitir que o
     LocalRestaurantLoader crie a data atual diretamente, podemos mover essa responsabilidade para fora do escopo da classe e injetá-la como uma dependência. Então, podemos
     facilmente controlar a data/hora atual durante os testes.
     */
    init(cache: CacheClient, currentDate: @escaping () -> Date) {
        self.cache = cache
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
}

extension LocalRestaurantLoader: RestaurantLoader {
    func load(completion: @escaping (Result<[RestaurantItem], RestaurantResultError>) -> Void) {
        cache.load { error in
            if error != nil {
                completion(.success([]))
            } else {
                completion(.failure(.invalidData))
            }
        }
    }
}
