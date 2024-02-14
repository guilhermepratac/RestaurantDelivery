//
//  CacheServiceTests.swift
//  RestaurantDomainTests
//
//  Created by Guilherme Prata Costa on 31/01/24.
//

import XCTest
@testable import RestaurantDomain

final class CacheServiceTests: XCTestCase {

    func save_and_returned_last_entered_value() {
        let path = type(of: self)
        let managerUrl: URL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appending(path: "\(path)")
        
        let sut = CacheService(managerUrl: managerUrl)
        let items = [makeItem(), makeItem()]
        let timestamp = Date()
        
        let returnedError = insert(sut, items: items, timestamp: timestamp)
        
        XCTAssertNil(returnedError)
    }
    
    func test_save_twice_and_returned_last_entered_value() {
        let path = type(of: self)
        let managerUrl: URL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appending(path: "\(path)")
        
        let sut = CacheService(managerUrl: managerUrl)
        let firstTimeItems = [makeItem(), makeItem()]
        let firstTimeTimestamp = Date()
        
        insert(sut, items: firstTimeItems, timestamp: firstTimeTimestamp)
                
        let secondTimeItems = [makeItem(), makeItem()]
        let secondTimeTimestamp = Date()

        insert(sut, items: secondTimeItems, timestamp: secondTimeTimestamp)
        
        assert(sut, completion: .sucess(secondTimeItems, timestamp: secondTimeTimestamp))
    }
}

extension CacheServiceTests {
    @discardableResult
    private func insert(_ sut: CacheClient, items: [RestaurantItem], timestamp: Date) -> Error? {
        let exp = expectation(description: "esperando o bloco ser completo")
        var returnedError: Error?

        sut.save(items, timestamp: timestamp) { error in
            returnedError = error
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 3.0)
            
        return returnedError
    }
    
    private func assert(
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
