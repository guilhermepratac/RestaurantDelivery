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
    func save(_ items: [RestaurantItem], timestamp: Date, completion: @escaping (Error?) -> Void)
    func delete(completion: @escaping (Error?) -> Void)
}

final class LocalRestaurantLoader {
    
    let cache: CacheClient
    let currentDate: () -> Date
    
    /*
     Controlando nosso tempo de cache nos testes de forma mais eficiente
     O Date() não é uma função pura porque toda vez que você cria uma instância de Data, ela tem um valor diferente - a data/hora atual, em vez de permitir que o LocalRestaurantLoader crie a data atual diretamente, podemos mover essa responsabilidade para fora do escopo da classe e injetá-la como uma dependência. Então, podemos facilmente controlar a data/hora atual durante os testes.
     */
    init(cache: CacheClient, currentDate: @escaping () -> Date) {
        self.cache = cache
        self.currentDate = currentDate
    }
    
    func save(_ items: [RestaurantItem], completion: @escaping (Error?) -> Void) {
        cache.delete { [unowned self] error in
            if error == nil {
                self.cache.save(items, timestamp: self.currentDate(), completion: completion)
            } else {
                completion(error)
            }
        }
    }
}
