//
//  CacheServiceTests.swift
//  RestaurantDomainTests
//
//  Created by Guilherme Prata Costa on 31/01/24.
//

import XCTest
@testable import RestaurantDomain

final class CacheServiceTests: XCTestCase {
    
    override func setUp() {
        super.setUp()

        try? FileManager.default.removeItem(at: validManagerURL() )
    }

    func save_and_returned_last_entered_value() {
        let sut = makeSUT()
        let items = [makeItem(), makeItem()]
        let timestamp = Date()
        
        insert(sut, items: items, timestamp: timestamp)
        assert(sut, completion: .sucess(items, timestamp: timestamp))
    }
    
    func test_save_twice_and_returned_last_entered_value() {
        let sut = makeSUT()
        let firstTimeItems = [makeItem(), makeItem()]
        let firstTimeTimestamp = Date()
        
        insert(sut, items: firstTimeItems, timestamp: firstTimeTimestamp)
                
        let secondTimeItems = [makeItem(), makeItem()]
        let secondTimeTimestamp = Date()

        insert(sut, items: secondTimeItems, timestamp: secondTimeTimestamp)
        
        assert(sut, completion: .sucess(secondTimeItems, timestamp: secondTimeTimestamp))
    }
    
    func test_save_error_when_invalid_manager_url() {
        let manager = invalidManagerURL()
        let sut = makeSUT(managerURL: manager)
        let items = [makeItem(), makeItem()]
        let timestamp = Date()
        
        let returnedError = insert(sut, items: items, timestamp: timestamp)
        
        XCTAssertNotNil(returnedError)
    }
    
    
    func test_delete_has_no_effect_to_delete_an_empty_cahce() {
        let sut = makeSUT()
        let items = [makeItem(), makeItem()]
        let timestamp = Date()
        
        assert(sut, completion: .empty)
        
        let returnedError = deleteCache(sut)
        
        XCTAssertNil(returnedError)
    }
    
    func test_delete_returned_empty_after_insert_new_data_cache() {
        let sut = makeSUT()
        let items = [makeItem(), makeItem()]
        let timestamp = Date()
        insert(sut, items: items, timestamp: timestamp)
        
        deleteCache(sut)
        
        assert(sut, completion: .empty)
    }
    
    func test_delete_returned_error_when_not_permission() {
        let sut = makeSUT(managerURL: invalidManagerURL())
        
        let returnedError = deleteCache(sut)
        
        XCTAssertNotNil(returnedError)
    }
    
    func test_load_returned_empty_cachen() {
        let sut = makeSUT()
        
        assert(sut, completion: .empty)
    }
    
    func test_load_returned_same_empty_cache_for_called_twice() {
        let sut = makeSUT()
        let sameResult: LoadResultState = .empty
        
        assert(sut, completion: sameResult)
        assert(sut, completion: sameResult)
    }
    
    func test_load_return_data_after_insert_data() {
        let sut = makeSUT()
        let items = [makeItem(), makeItem()]
        let timestamp = Date()
        
        insert(sut, items: items, timestamp: timestamp)
        assert(sut, completion: .sucess(items, timestamp: timestamp))
    }
    
    func test_load_returned_error_when_non_decode_data_cache() {
        let manager = validManagerURL()
        let sut = makeSUT(managerURL: manager)
        let anyError = NSError(domain: "anyerror", code: -1)
        
        
        try? "invalidData".write(to: manager, atomically: false, encoding: .utf8)
        
        assert(sut, completion: .failure(anyError))
        
    }
}

private extension CacheServiceTests {
    func makeSUT(managerURL: URL? = nil) -> CacheService {
        return CacheService(managerUrl: managerURL ?? validManagerURL())
    }
    
    func validManagerURL() -> URL {
        let path = type(of: self)
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appending(path: "\(path)")
    }
    
    func invalidManagerURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    @discardableResult
    func insert(_ sut: CacheClient, items: [RestaurantItem], timestamp: Date) -> Error? {
        let exp = expectation(description: "esperando o bloco ser completo")
        var returnedError: Error?

        sut.save(items, timestamp: timestamp) { error in
            returnedError = error
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 3.0)
            
        return returnedError
    }
    
    @discardableResult
    func deleteCache(_ sut: CacheClient) -> Error? {
        let exp = expectation(description: "esperando o bloco ser completo")
        var returnedError: Error?

        sut.delete { error in
            returnedError = error
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 3.0)
            
        return returnedError
    }
    
    func assert(
        _ sut: CacheClient,
        completion result: LoadResultState,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {

        let exp = expectation(description: "esperando o bloco ser completo")
        sut.load { returnedResult in
            switch (result, returnedResult) {
            case (.empty, .empty), (.failure, .failure): break
            case let (.sucess(items, timestamp), .sucess(returnedItems, returnedTimestamp)):
                XCTAssertEqual(returnedItems, items)
                XCTAssertEqual(returnedTimestamp, timestamp)
                
            default:
                XCTFail("esperando retorno \(result), porem retornou \(returnedResult)", file: file, line: line)
            }
            exp.fulfill()

        }
        
        wait(for: [exp], timeout: 3.0)

    }
}
