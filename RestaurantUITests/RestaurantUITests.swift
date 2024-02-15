//
//  RestaurantUITests.swift
//  RestaurantUITests
//
//  Created by Guilherme Prata Costa on 14/02/24.
//

import XCTest
import RestaurantDomain
@testable import RestaurantUI

final class RestaurantUITests: XCTestCase {
    private func makeSUT(
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: RestaurantListViewController, service: RestaurantLoaderSpy) {
        let service = RestaurantLoaderSpy()
        let sut = RestaurantListViewController(service: service)
        trackForMemoryLeak(sut, file: file, line: line)
        trackForMemoryLeak(service, file: file, line: line)
        return (sut, service)
    }
    
    func test_init_does_not_load() {
        let (_, service) =  makeSUT()
        XCTAssertEqual(service.loadCount, 0)
    }
    
    func test_viewDidLoad_should_be_called_load_service() {
        let (sut, service) = makeSUT()

        sut.loadViewIfNeeded()

        XCTAssertEqual(service.loadCount, 1)
    }
    
    func test_load_returned_restaurantItems_data_and_restaurantCollection_does_not_empty() {
        let (sut, service) = makeSUT()

        sut.loadViewIfNeeded()
        service.completionResult(.success([makeItem()]))

        XCTAssertEqual(service.loadCount, 1)
        XCTAssertEqual(sut.restaurantCollection.count, 1)
    }
    
    func test_load_returned_error_and_restaurantCollection_is_empty() {
        let (sut, service) = makeSUT()

        sut.loadViewIfNeeded()
        service.completionResult(.failure(.invalidData))

        XCTAssertEqual(service.loadCount, 1)
        XCTAssertEqual(sut.restaurantCollection.count, 0)
    }

}


final class RestaurantLoaderSpy: RestaurantLoader {
    private(set) var loadCount = 0
    private var completionLoadHandler: ((RestaurantResult) -> Void)?

    func load(completion: @escaping (RestaurantResult) -> Void) {
        loadCount+=1
        completionLoadHandler = completion
    }
    
    func completionResult(_ result: RestaurantResult) {
        completionLoadHandler?(result)
    }
}
