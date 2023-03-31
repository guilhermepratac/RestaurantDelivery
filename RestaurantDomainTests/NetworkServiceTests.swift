//
//  NetworkServiceTests.swift
//  RestaurantDomainTests
//
//  Created by Guilherme Prata Costa on 31/03/23.
//

import XCTest
@testable import RestaurantDomain

final class URLSessionSpy: URLSession {
    private(set) var urlRequest: URL?
    
    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        urlRequest = url
        return URLSessionDataTask()
    }
    
}

final class NetworkServiceTests: XCTestCase {
    func test_request_and_create_dataTask_with_url() throws {
        let (sut, Doubles) = makeSUT()
        
        sut.request(from: Doubles.anyURL) { _ in }
                
        XCTAssertEqual(Doubles.session.urlRequest, Doubles.anyURL)
    }
    
    
}

private extension NetworkServiceTests {
    typealias Doubles = (
        session: URLSessionSpy,
        anyURL: URL
    )
    
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: NetworkService, Doubles) {
        let anyURL: URL = URL(string: "https://comitando.com.br")!
        let session = URLSessionSpy()
        let sut = NetworkService(session: session)
        trackForMemoryLeak(session, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        
        return (sut,(session,anyURL))
    }
    
    func trackForMemoryLeak(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "A instancia deveria ter sido desalocada, possível vazamento de memória", file: file, line: line)
        }
    }
}
