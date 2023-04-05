//
//  URLSessionDataTaskSpy.swift
//  RestaurantDomainTests
//
//  Created by Guilherme Prata Costa on 05/04/23.
//

import Foundation

final class URLSessionDataTaskSpy: URLSessionDataTask {
    private(set) var resumeCont: Int = 0
    override func resume() {
        resumeCont += 1
    }
}

final class FakeURLSessionDataTaskSpy: URLSessionDataTask {
    override func resume() { }
}
