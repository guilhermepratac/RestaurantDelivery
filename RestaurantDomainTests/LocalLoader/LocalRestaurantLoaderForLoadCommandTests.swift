//
//  LocalRestaurantLoaderForSaveCommandTests.swift
//  RestaurantDomainTests
//
//  Created by Guilherme Prata Costa on 21/06/23.
//

import XCTest
@testable import RestaurantDomain

final class LocalRestaurantLoaderForLoadCommandTests: XCTestCase {
    func test_load_returned_completion_sucess_with_empty_data() {
        let ( sut, Doubles ) = makeSUT()
        
        assert(sut, completion: .success([]) ) {
            Doubles.cache.completionHandlerForLoad(.empty)
        }
        
        XCTAssertEqual(Doubles.cache.messages, [.load])
    }
    
    func test_load_returned_data_with_one_day_less_than_old_cache() {
        let currentDate = Date()
        let oneDayLessThanOldCacheDate = currentDate.addinng(days: -1).adding(seconds: 1)
        let ( sut, Doubles ) = makeSUT(currentDate: currentDate)
        let items = [makeItem()]
        
        assert(sut, completion: .success(items) ) {
            Doubles.cache.completionHandlerForLoad(.sucess(items, timestamp: oneDayLessThanOldCacheDate))
        }
        
        XCTAssertEqual(Doubles.cache.messages, [.load])
    }
    
    func test_load_returned_data_with_one_day_more_than_old_cache() {
        let currentDate = Date()
        let oneDayOldCacheDate = currentDate.addinng(days: -1)
        let ( sut, Doubles ) = makeSUT(currentDate: currentDate)
        let items = [makeItem()]
        
        assert(sut, completion: .success([]) ) {
            Doubles.cache.completionHandlerForLoad(.sucess(items, timestamp: oneDayOldCacheDate))
        }
        
        XCTAssertEqual(Doubles.cache.messages, [.load])
    }
    
    func test_load_returned_completion_failure_with_error() {
        let ( sut, Doubles ) = makeSUT()
        
        assert(sut, completion: .failure(.invalidData)) {
            let anyError = NSError(domain: "any error", code: -1)
            Doubles.cache.completionHandlerForLoad(.failure(anyError))
        }
        
        XCTAssertEqual(Doubles.cache.messages, [.load])
    }
}

private extension LocalRestaurantLoaderForLoadCommandTests {
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
    
    private func assert(
        _ sut: LocalRestaurantLoader,
        completion result: (Result<[RestaurantItem], RestaurantResultError>)??,
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        
        var returnedResult: (Result<[RestaurantItem], RestaurantResultError>)?
        sut.load { result in
            returnedResult = result
        }
        
        action()
        
        XCTAssertEqual(returnedResult, result)
    }
}
