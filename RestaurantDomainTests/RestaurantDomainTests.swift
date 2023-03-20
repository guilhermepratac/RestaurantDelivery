//
//  RestaurantDomainTests.swift
//  RestaurantDomainTests
//
//  Created by Guilherme Prata Costa on 15/02/23.
//

import XCTest
@testable import RestaurantDomain

final class RestaurantDomainTests: XCTestCase {

    func test_initializer_remoteRestaurantLoader_and_validate_urlRequest() throws {
        let anyURL: URL = try XCTUnwrap(URL(string: "https://comitando.com.br"))
        let client = NetworkClientSpy()
        let sut = RemoteRestaurantLoader(url: anyURL, networkClient: client)
        
        
        sut.load()
                
        XCTAssertEqual(client.urlRequest, anyURL)
    }

}

final class NetworkClientSpy: NetworkClient {
    private(set) var urlRequest: URL?

    func request(from url: URL) {
        urlRequest = url
    }
}
