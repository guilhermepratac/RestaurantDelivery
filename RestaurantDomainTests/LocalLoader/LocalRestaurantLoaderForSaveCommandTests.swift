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
    
    func test_saveCommand_returned_error_when_delete() {
        let ( sut, Doubles ) = makeSUT()
        let anyError = NSError(domain: "any error", code: -1)
        
        assert(sut, completion: anyError) {
            Doubles.cache.completionHandlerForDelete(anyError)
        }
        
        XCTAssertEqual(Doubles.cache.messages, [.delete])
    }
    
    func test_saveCommand_returned_error_when_save() {
        let currentDate = Date()
        let ( sut, Doubles ) = makeSUT(currentDate: currentDate)
        let anyError = NSError(domain: "any error", code: -1)
        let items = [makeItem()]
        
        assert(sut, completion: anyError, items: items) {
            Doubles.cache.completionHandlerForDelete()
            Doubles.cache.completionHandlerForSave(anyError)
        }
        
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
    
    private func assert(
        _ sut: LocalRestaurantLoader,
        completion error: NSError,
        items: [RestaurantItem] = [makeItem()],
        when action: () -> Void,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {

        var returnedError: Error?
        sut.save(items) { error in
            returnedError = error
        }
        
        action()
        
        XCTAssertEqual(returnedError as? NSError, error)
    }
}
