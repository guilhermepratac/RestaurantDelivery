//
//  LocalRestaurantLoaderForSaveCommandTests.swift
//  RestaurantDomainTests
//
//  Created by Guilherme Prata Costa on 21/06/23.
//

import XCTest
@testable import RestaurantDomain

final class LocalRestaurantLoaderForValidateCacheCommandTests: XCTestCase {
    func test_load_delete_cache_after_error_to_load() {
        let ( sut, Doubles ) = makeSUT()
        
        sut.validateCache()
        
        let anyError = NSError(domain: "any error", code: -1)
        Doubles.cache.completionHandlerForLoad(.failure(anyError))
        
        XCTAssertEqual(Doubles.cache.messages, [.load, .delete])
    }
    
    func test_load_noDelete_cache_after_empty_result() {
        let ( sut, Doubles ) = makeSUT()
        
        sut.validateCache()
        Doubles.cache.completionHandlerForLoad(.empty)
        
        XCTAssertEqual(Doubles.cache.messages, [.load])
    }
    
    func test_load_returned_data_with_one_day_more_than_old_cache() {
        let currentDate = Date()
        let oneDayMoreOldCacheDate = currentDate.addinng(days: -1)
        let ( sut, Doubles ) = makeSUT(currentDate: currentDate)
        let items = [makeItem()]
        
        sut.validateCache()
        Doubles.cache.completionHandlerForLoad(.sucess(items, timestamp: oneDayMoreOldCacheDate))
        
        XCTAssertEqual(Doubles.cache.messages, [.load, .delete])
    }
    

}

private extension LocalRestaurantLoaderForValidateCacheCommandTests {
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
}
