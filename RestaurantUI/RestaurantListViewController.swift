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
 - [x] Habilitar recurso para atualização manual (pull to refresh)
 - [x] Exibir um loading indicativo, durante processo de carregamento
 - [ ] Renderizar todas as informações disponíveis de restaurantes

 */

class RestaurantListViewController: UITableViewController {
    
    private(set) var restaurantCollection: [RestaurantItem] = []
    private var service: RestaurantLoader? = nil
    
    convenience init(service: RestaurantLoader){
        self.init()
        self.service = service
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRefreshControll()
        loadService()
    }
    
    private func setupRefreshControll() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(loadService), for: .valueChanged)
        refreshControl?.beginRefreshing()
    }
    
    @objc func loadService() {
        service?.load { [weak self] result in
            guard let self else { return }
            switch result {
            case let .success(items):
                self.restaurantCollection = items
            default: break
            }
            
            self.refreshControl?.endRefreshing()
        }
    }
}
