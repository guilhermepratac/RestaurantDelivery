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
        
        XCTAssertEqual(Doubles.cache.deleteCount, 1)
    }
}

private extension LocalRestaurantLoaderTests {
    typealias Doubles = (
        cache: CacheClientSpy,
        currentDate: Date
    )
    
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalRestaurantLoader, Doubles) {
        let currentDate = Date()
        let client = CacheClientSpy()
        let sut = LocalRestaurantLoader(cache: client, currentDate: { currentDate })
        trackForMemoryLeak(client, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        
        return (sut,(client, currentDate))
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
        client: CacheClientSpy,
        items: [RestaurantItem],
        completion result: (Error?) -> Void,
        when action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Esperando retorno da closure")
        //var returnedResult: (Error?) -> Void
        sut.save(items, completion: { result in
            //returnedResult = result
            exp.fulfill()
        })
        
        action()
        
        wait(for: [exp], timeout: 1.0)
                
        //XCTAssertEqual(returnedResult, result)
    }
}

final class CacheClientSpy: CacheClient {
    func save(_ items: [RestaurantDomain.RestaurantItem], timestamp: Date, completion: @escaping (Error?) -> Void) {
        
    }
    
    private(set) var deleteCount = 0
    func delete(completion: @escaping (Error?) -> Void) {
        deleteCount += 1
    }
}
