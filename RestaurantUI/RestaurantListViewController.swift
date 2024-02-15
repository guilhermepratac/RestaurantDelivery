//
//  RestaurantViewController.swift
//  RestaurantUI
//
//  Created by Guilherme Prata Costa on 14/02/24.
//

import UIKit
import RestaurantDomain

/*
 ### Lista de restaurantes UI
 - [x] Carregamento automático da lista de restaurantes, quando a tela for exibida
 - [ ] Habilitar recurso para atualização manual (pull to refresh)
 - [ ] Exibir um loading indicativo, durante processo de carregamento
 - [ ] Renderizar todas as informações disponíveis de restaurantes

 */

class RestaurantListViewController: UIViewController {
    
    private(set) var restaurantCollection: [RestaurantItem] = []
    private var service: RestaurantLoader? = nil
    
    convenience init(service: RestaurantLoader){
        self.init()
        self.service = service
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        service?.load { [weak self] result in
            guard let self else { return }
            switch result {
            case let .success(items):
                self.restaurantCollection = items
            default: break
            }
        }

    }
}
