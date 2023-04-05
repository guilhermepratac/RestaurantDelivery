//
//  NetworkServiceTests.swift
//  RestaurantDomainTests
//
//  Created by Guilherme Prata Costa on 31/03/23.
//

import XCTest
@testable import RestaurantDomain

final class URLSessionSpy: URLSession {
    //Esse stubs serve para que possamos saber se DataTask pertence a URL passada, caso haja duas chamadas precisamos garantir que retorno 1 seja da url 1
    private(set) var stubs: [URL: Stub] = [:]
    
    struct Stub {
        let task: URLSessionDataTask
        let data: Data?
        let response: URLResponse?
        let error: Error?
    }
 
    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        guard let stub = stubs[url] else {
            return FakeURLSessionDataTaskSpy()
        }
        
        completionHandler(nil, nil, stub.error)
        return stub.task
    }
    
    func stub(with url: URL, task: URLSessionDataTask, data: Data? = nil, response: URLResponse? = nil, error: Error? = nil) {
        stubs[url] = Stub(task: task, data: data, response: response, error: error)
    }
}

final class URLSessionDataTaskSpy: URLSessionDataTask {
    
    private(set) var resumeCont: Int = 0
    override func resume() {
        resumeCont += 1
    }
}

final class FakeURLSessionDataTaskSpy: URLSessionDataTask {
    override func resume() { }
}

final class NetworkServiceTests: XCTestCase {
    func test_request_and_resume_dataTask_with_url() throws {
        let (sut, Doubles) = makeSUT()
        Doubles.session.stub(with: Doubles.anyURL, task: Doubles.task)
        
        sut.request(from: Doubles.anyURL) { _ in }
                
        XCTAssertEqual(Doubles.task.resumeCont, 1)
    }
    
    func test_request_and_completion_with_error() throws{
        let anyError = NSError(domain: "any error", code: -1)
        let returnedResult = assert(data: nil, response: nil, error: anyError)
        
        switch returnedResult {
        case let .failure(returnedError):
            XCTAssertEqual(returnedError as? NSError, anyError)
        default:
            XCTFail("Esperando falha mas retorno \(String(describing: returnedResult))")
        }
    }
    
    func test_request_and_completion_with_sucess() throws{
        let (_, Doubles) = makeSUT()

        let data = Data()
        let response = HTTPURLResponse(url: Doubles.anyURL, statusCode: 200, httpVersion: nil, headerFields: nil)
        let returnedResult = assert(data: data, response: response, error: nil)
        
        switch returnedResult {
        case let .success((returnedData, returnedResponse)):
            XCTAssertEqual(returnedData, data)
            XCTAssertEqual(returnedResponse, response)

        default:
            XCTFail("Esperando sucesso mas retorno \(String(describing: returnedResult))")
        }
    }
}

private extension NetworkServiceTests {
    typealias Doubles = (
        session: URLSessionSpy,
        anyURL: URL,
        task: URLSessionDataTaskSpy
    )
    
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: NetworkService, Doubles) {
        let anyURL: URL = URL(string: "https://comitando.com.br")!
        let session = URLSessionSpy()
        let task = URLSessionDataTaskSpy()
        let sut = NetworkService(session: session)
        trackForMemoryLeak(session, file: file, line: line)
        trackForMemoryLeak(sut, file: file, line: line)
        
        return (sut,(session, anyURL, task))
    }
    
    func trackForMemoryLeak(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "A instancia deveria ter sido desalocada, possível vazamento de memória", file: file, line: line)
        }
    }
    
    private func assert(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> NetworkService.NetworkResult? {

        let (sut, Doubles) = makeSUT()
        let url = URL(string: "https://comitando.com.br")!
        Doubles.session.stub(with: url, task: Doubles.task, data: data, response: response, error: error)

        let exp = expectation(description: "aguardando retorno da clousure")
        var returnedResult: NetworkService.NetworkResult?
        sut.request(from: url) { result in
            returnedResult = result
            exp.fulfill()
        }

        wait(for: [exp], timeout: 1.0)

        return returnedResult
    }
}
