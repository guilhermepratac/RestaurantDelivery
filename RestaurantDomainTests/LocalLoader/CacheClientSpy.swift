//
//  CacheClientSpy.swift
//  RestaurantDomainTests
//
//  Created by Guilherme Prata Costa on 21/06/23.
//

import Foundation
@testable import RestaurantDomain

final class CacheClientSpy: CacheClient {
    enum Messages: Equatable {
        case delete
        case save([RestaurantItem], Date)
        case load
    }
    
    private(set) var messages: [Messages] = []
    
    func load(completion: @escaping LoadResult) {
        messages.append(.load)
    }
    
    private var completionHandlerSave: ((Error?) -> Void)?
    func save(_ items: [RestaurantDomain.RestaurantItem], timestamp: Date, completion: @escaping (Error?) -> Void) {
        completionHandlerSave = completion
        messages.append(.save(items, timestamp))
    }
    
    private var completionHandlerDelete: ((Error?) -> Void)?
    func delete(completion: @escaping (Error?) -> Void) {
        completionHandlerDelete = completion
        messages.append(.delete)
    }
    
    func completionHandlerForDelete(_ error: Error? = nil) {
        completionHandlerDelete?(error)
    }
    
    func completionHandlerForSave(_ error: Error? = nil) {
        completionHandlerSave?(error)
    }
}
