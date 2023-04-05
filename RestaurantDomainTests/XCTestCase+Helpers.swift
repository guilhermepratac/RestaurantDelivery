//
//  XCTestCase+Helpers.swift
//  RestaurantDomainTests
//
//  Created by Guilherme Prata Costa on 05/04/23.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeak(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "A instancia deveria ter sido desalocada, possível vazamento de memória", file: file, line: line)
        }
    }
}
