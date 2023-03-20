//
//  RemoteRestaurantLoaderTests.swift
//  RestaurantDomainTests
//
//  Created by Guilherme Prata Costa on 20/03/23.
//

import XCTest
@testable import RestaurantDomain

final class RemoteRestaurantLoaderTests: XCTestCase {

    func test_initializer_remoteRestaurantLoader_and_validate_urlRequest() throws {
        let (sut, Doubles) = makeSUT()
        Doubles.client.stateHandler = .sucess

        
        sut.load() {_ in }
                
        XCTAssertEqual(Doubles.client.urlRequests, [Doubles.anyURL])
    }
    
    func test_load_and_returned_error_for_invalidData() throws {
        let (sut, Doubles) = makeSUT()
        Doubles.client.stateHandler = .sucess

        let exp = expectation(description: "Esperando retorno da closure")
        var returnedResult: RemoteRestaurantLoader.Error?
        sut.load() { result in
            returnedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
                
        XCTAssertNotNil(returnedResult)
    }
    
    func test_load_and_returned_error_for_connectivitiy() throws {
        let (sut, Doubles) = makeSUT()
        Doubles.client.stateHandler = .error(NSError(domain: "any error", code: -1))
        
        let exp = expectation(description: "Esperando retorno da closure")
        var returnedResult: RemoteRestaurantLoader.Error?
        sut.load() { result in
            returnedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
                
        XCTAssertNotNil(returnedResult)
    }


}

private extension RemoteRestaurantLoaderTests {
    typealias Doubles = (
        client: NetworkClientSpy,
        anyURL: URL
    )
    
    func makeSUT() -> (sut: RemoteRestaurantLoader, Doubles) {
        let anyURL: URL = URL(string: "https://comitando.com.br")!
        let client = NetworkClientSpy()
        let sut = RemoteRestaurantLoader(url: anyURL, networkClient: client)
        
        return (sut,(client,anyURL))
    }
}

final class NetworkClientSpy: NetworkClient {
    private(set) var urlRequests: [URL] = []
    var stateHandler: NetworkState?

    func request(from url: URL, completion: @escaping (NetworkState) -> Void) {
        urlRequests.append(url)
        completion( stateHandler ?? .error(anyError()))
    }
    
    private func anyError () -> Error {
        return NSError(domain: "any error", code: -1)
    }
}

