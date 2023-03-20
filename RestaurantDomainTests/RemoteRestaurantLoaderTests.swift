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
    
    func test_load_and_returned_sucess_with_restaurant_item_list() throws {
        let (sut, Doubles) = makeSUT()
        
        let exp = expectation(description: "Esperando retorno da closure")
        var returnedResult: RemoteRestaurantLoader.RemoteRestaurantResult?
        
        sut.load() { result in
            returnedResult = result
            exp.fulfill()
        }
        
        let (model1, json1) = makeItem()
        let (model2, json2) = makeItem()
        let (model3, json3) = makeItem()

        let jsonItem = ["items": [json1, json2, json3]]
        let data = try XCTUnwrap(JSONSerialization.data(withJSONObject: jsonItem))
        
        Doubles.client.completionWithSucess(data: data)
        
        wait(for: [exp], timeout: 1.0)
                
        XCTAssertEqual(returnedResult, .success([model1, model2, model3]))
    }
    
    func test_load_and_returned_error_for_invalid_statusCode() throws {
        let (sut, Doubles) = makeSUT()

        let exp = expectation(description: "Esperando retorno da closure")
        var returnedResult: RemoteRestaurantLoader.RemoteRestaurantResult?
        sut.load() { result in
            returnedResult = result
            exp.fulfill()
        }
        
        let (_, json1) = makeItem()

        let jsonItem = ["items": [json1]]
        let data = try XCTUnwrap(JSONSerialization.data(withJSONObject: jsonItem))
        Doubles.client.completionWithSucess(statusCode: 201, data: data)

        
        wait(for: [exp], timeout: 1.0)
                
        XCTAssertEqual(returnedResult, .failure(.invalidData))
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
    
    private func makeItem(id: UUID = UUID(),
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

