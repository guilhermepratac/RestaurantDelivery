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
        let sut = RemoteRestaurantLoader(url: anyURL)
        
        sut.load()
                
        XCTAssertNotNil(NetworkClient.shared.urlRequest)
    }

}
