//
//  LocalRestaurantLoaderForSaveCommandTests.swift
//  RestaurantDomainTests
//
//  Created by Guilherme Prata Costa on 21/06/23.
//

import XCTest
@testable import RestaurantDomain

final class LocalRestaurantLoaderForSaveCommandTests: XCTestCase {    
    func test_save_delete_old_cache() {
        let ( sut, Doubles ) = makeSUT()
        let model = makeItem()
        let items: [RestaurantItem] = [model]
        
        sut.save(items) { _ in }
        
        XCTAssertEqual(Doubles.cache.messages, [.delete])
    }
    
    func test_saveCommand_insert_new_data_on_cache() {
        let currentDate: Date = Date()
        let ( sut, Doubles ) = makeSUT(currentDate: currentDate)
        let model = makeItem()
        let items: [RestaurantItem] = [model]
        
        sut.save(items) { _ in }
        Doubles.cache.completionHandlerForDelete()
        
        XCTAssertEqual(Doubles.cache.messages, [.delete, .save(items, currentDate)])
    }
}

private extension LocalRestaurantLoaderForSaveCommandTests {
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
    
    func makeItem(id: UUID = UUID(),
                          name: String = "name",
                          location: String = "location",
                          distance: Float = 4.5,
                          ratings: Int = 4,
                          parasols: Int = 10
    ) -> RestaurantItem {
        let item = RestaurantItem(id: id,
                                  name: name,
                                  location: location,
                                  distance: distance,
                                  ratings: ratings,
                                  parasols: parasols)
        
        return item
    }
}
