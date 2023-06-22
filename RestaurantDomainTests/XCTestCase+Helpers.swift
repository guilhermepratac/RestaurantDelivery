//
//  XCTestCase+Helpers.swift
//  RestaurantDomainTests
//
//  Created by Guilherme Prata Costa on 05/04/23.
//

import XCTest
@testable import RestaurantDomain

extension XCTestCase {
    func trackForMemoryLeak(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "A instancia deveria ter sido desalocada, possível vazamento de memória", file: file, line: line)
        }
    }
}

func makeItem(id: UUID = UUID(),
                      name: String = "name",
                      location: String = "location",
                      distance: Float = 4.5,
                      ratings: Int = 4,
                      parasols: Int = 10
) -> RestaurantItem {
    let item = RestaurantItem(id: id,
                              name: name,
                              location: location,
                              distance: distance,
                              ratings: ratings,
                              parasols: parasols)
    
    return item
}

extension Date {
    func addinng(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
