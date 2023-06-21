//
//  RemoteRestaurantLoaderTests.swift
//  RestaurantDomainTests
//
//  Created by Guilherme Prata Costa on 20/03/23.
//

import XCTest
import RestaurantDomain

final class RemoteRestaurantLoaderTests: XCTestCase {

    func test_initializer_remoteRestaurantLoader_and_validate_urlRequest() throws {
        let (sut, Doubles) = makeSUT()

        
        sut.load() {_ in }
        Doubles.client.completionWithSucess()

                
        XCTAssertEqual(Doubles.client.urlRequests, [Doubles.anyURL])
    }
    
    func test_load_and_returned_error_for_invalidData() throws {
        let (sut, Doubles) = makeSUT()

        assert(sut, client: Doubles.client, completion: .failure(.invalidData)) {
            Doubles.client.completionWithSucess()
        }
    }
    
    func test_load_and_returned_error_for_connectivitiy() throws {
        let (sut, Doubles) = makeSUT()
        
        assert(sut, client: Doubles.client, completion: .failure(.connectivitiy)) {
            Doubles.client.completionWithError()
        }
    }
    
    func test_load_and_returned_sucess_with_empaty_List() throws {
        let (sut, Doubles) = makeSUT()
        
        assert(sut, client: Doubles.client, completion: .success([])) {
            Doubles.client.completionWithSucess(data: emptyData())
        }
    }
    
    func test_load_and_returned_sucess_with_restaurant_item_list() throws {
        let (sut, Doubles) = makeSUT()

        let (model1, json1) = makeItem()
        let (model2, json2) = makeItem()
        let (model3, json3) = makeItem()
        let jsonItem = ["items": [json1, json2, json3]]
        let data = try XCTUnwrap(JSONSerialization.data(withJSONObject: jsonItem))
        
        assert(sut, client: Doubles.client, completion: .success([model1, model2, model3])) {
            Doubles.client.completionWithSucess(data: data)
        }
    }
    
    func test_load_and_returned_error_for_invalid_statusCode() throws {
        let (sut, Doubles) = makeSUT()
        
        let (_, json1) = makeItem()

        let jsonItem = ["items": [json1]]
        let data = try XCTUnwrap(JSONSerialization.data(withJSONObject: jsonItem))
        
        assert(sut, client: Doubles.client, completion: .failure(.invalidData)) {
            Doubles.client.completionWithSucess(statusCode: 201, data: data)
        }
    }

    func test_load_not_returned_after_sut_deallocated() throws {
        let anyURL: URL = URL(string: "https://comitando.com.br")!
        let client = NetworkClientSpy()
        var sut: RemoteRestaurantLoader? = RemoteRestaurantLoader(url: anyURL, networkClient: client)

        var returnedResult: RemoteRestaurantLoader.RestaurantLoaderResult?
        sut?.load(completion: { result in
            returnedResult = result
        })
        
        sut = nil
        client.completionWithSucess()
        
        XCTAssertNil(returnedResult)
    }
    
}

private extension RemoteRestaurantLoaderTests {
    typealias Doubles = (
        client: NetworkClientSpy,
        anyURL: URL
    )
    
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: RemoteRestaurantLoader, Doubles) {
        let anyURL: URL = URL(string: "https://comitando.com.br")!
        let client = NetworkClientSpy()
        let sut = RemoteRestaurantLoader(url: anyURL, networkClient: client)
        trackForMemoryLeak(client, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        
        return (sut,(client,anyURL))
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
        _ sut: RemoteRestaurantLoader,
        client: NetworkClientSpy,
        completion result: RemoteRestaurantLoader.RestaurantLoaderResult,
        when action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Esperando retorno da closure")
        var returnedResult: RemoteRestaurantLoader.RestaurantLoaderResult?
        sut.load(completion: { result in
            returnedResult = result
            exp.fulfill()
        })
        
        action()
        
        wait(for: [exp], timeout: 1.0)
                
        XCTAssertEqual(returnedResult, result)
    }
}
