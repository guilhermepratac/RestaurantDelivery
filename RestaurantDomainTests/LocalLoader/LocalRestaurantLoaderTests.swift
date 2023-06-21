//
//  LocalRestaurantLoader.swift
//  RestaurantDomainTests
//
//  Created by Guilherme Prata Costa on 21/06/23.
//

import XCTest
@testable import RestaurantDomain

final class LocalRestaurantLoaderTests: XCTestCase {
    func test_save_delete_old_cache() {
        let ( sut, Doubles ) = makeSUT()
        let (model, _) = makeItem()
        let items: [RestaurantItem] = [model]
        
        sut.save(items) { _ in }
        
        XCTAssertEqual(Doubles.cache.messages, [.delete])
    }
    
    func test_saveCommand_insert_new_data_on_cache() {
        let currentDate: Date = Date()
        let ( sut, Doubles ) = makeSUT(currentDate: currentDate)
        let (model, _) = makeItem()
        let items: [RestaurantItem] = [model]
        
        sut.save(items) { _ in }
        Doubles.cache.completionHandlerForDelete()
        
        XCTAssertEqual(Doubles.cache.messages, [.delete, .save(items, currentDate)])
    }
}

private extension LocalRestaurantLoaderTests {
    typealias Doubles = (
        cache: CacheClientSpy,
        currentDate: Date
    )
    
    func makeSUT(currentDate: Date = Date(), file: StaticString = #file, line: UInt = #line) -> (sut: LocalRestaurantLoader, Doubles) {
        let cache = CacheClientSpy()
        let sut = LocalRestaurantLoader(cache: cache, currentDate: { currentDate })
        trackForMemoryLeak(cache, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        
        return (sut,(cache, currentDate))
    }

    
    func emptyData() -> Data{
        return Data("{ \"items\":[] }".utf8)
    }
    
    func makeItem(id: UUID = UUID(),
                          name: String = "name",
                          location: String = "location",
                          distance: Float = 4.5,
                          ratings: Int = 4,
                          parasols: Int = 10
    ) -> (mode: RestaurantItem, json: [String: Any]) {
        let item = RestaurantItem(id: id,
                                  name: name,
                                  location: location,
                                  distance: distance,
                                  ratings: ratings,
                                  parasols: parasols)
        
        let itemJson: [String: Any] = [
            "id": item.id.uuidString,
            "name": item.name,
            "location": item.location,
            "distance": item.distance,
            "ratings": item.ratings,
            "parasols": item.parasols
        ]
        
        return (item, itemJson)
    }
    
    func assert(
        _ sut: LocalRestaurantLoader,
        cache: CacheClientSpy,
        items: [RestaurantItem],
        error: Error? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Esperando retorno da closure")
        sut.save(items) { _ in
            exp.fulfill()
        }
        cache.completionHandlerForDelete(error)
        
        wait(for: [exp], timeout: 1.0)
                
        //XCTAssertEqual(returnedResult, result)
    }
}

final class CacheClientSpy: CacheClient {
    
    enum Messages: Equatable {
        case delete
        case save([RestaurantItem], Date)
    }
    
    private(set) var messages: [Messages] = []
    
    private(set) var saveCount = 0
    func save(_ items: [RestaurantDomain.RestaurantItem], timestamp: Date, completion: @escaping (Error?) -> Void) {
        messages.append(.save(items, timestamp))
    }
    
    private(set) var deleteCount = 0
    private var completionHandler: ((Error?) -> Void)?
    func delete(completion: @escaping (Error?) -> Void) {
        completionHandler = completion
        messages.append(.delete)
    }
    
    func completionHandlerForDelete(_ error: Error? = nil) {
        completionHandler?(error)
    }
}
