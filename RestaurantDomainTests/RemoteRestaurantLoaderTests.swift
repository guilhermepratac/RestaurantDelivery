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

        
        sut.load() {_ in }
        Doubles.client.completionWithSucess()

                
        XCTAssertEqual(Doubles.client.urlRequests, [Doubles.anyURL])
    }
    
    func test_load_and_returned_error_for_invalidData() throws {
        let (sut, Doubles) = makeSUT()

        let exp = expectation(description: "Esperando retorno da closure")
        var returnedResult: RemoteRestaurantLoader.RemoteRestaurantResult?
        sut.load() { result in
            returnedResult = result
            exp.fulfill()
        }
        Doubles.client.completionWithSucess()

        
        wait(for: [exp], timeout: 1.0)
                
        XCTAssertEqual(returnedResult, .failure(.invalidData))
    }
    
    func test_load_and_returned_error_for_connectivitiy() throws {
        let (sut, Doubles) = makeSUT()
        
        let exp = expectation(description: "Esperando retorno da closure")
        var returnedResult: RemoteRestaurantLoader.RemoteRestaurantResult?
        sut.load() { result in
            returnedResult = result
            exp.fulfill()
        }
        Doubles.client.completionWithError()

        
        wait(for: [exp], timeout: 1.0)
                
        XCTAssertEqual(returnedResult, .failure(.connectivitiy))
    }
    
    func test_load_and_returned_sucess_with_empaty_List() throws {
        let (sut, Doubles) = makeSUT()
        
        let exp = expectation(description: "Esperando retorno da closure")
        var returnedResult: RemoteRestaurantLoader.RemoteRestaurantResult?
        sut.load() { result in
            returnedResult = result
            exp.fulfill()
        }
        
        
        Doubles.client.completionWithSucess(data: emptyData())

        
        wait(for: [exp], timeout: 1.0)
                
        XCTAssertEqual(returnedResult, .success([]))
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
    
    private func emptyData() -> Data{
        return Data("{ \"items\":[] }".utf8)
    }
}

final class NetworkClientSpy: NetworkClient {
    private(set) var urlRequests: [URL] = []
    private var completionHandler: ((NetworkResult) -> Void)?

    func request(from url: URL, completion: @escaping (NetworkResult) -> Void) {
        urlRequests.append(url)
        completionHandler = completion
    }
    
    func completionWithError() {
        completionHandler?(.failure(anyError()))
    }
    
    
    func completionWithSucess(statusCode: Int = 200, data: Data = Data()) {
        let response = HTTPURLResponse(url: urlRequests[0], statusCode: statusCode, httpVersion: nil, headerFields: nil)!
        completionHandler?(.success( (data, response) ))
    }
    
    private func anyError () -> Error {
        return NSError(domain: "any error", code: -1)
    }
}

