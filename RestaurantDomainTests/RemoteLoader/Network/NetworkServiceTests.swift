//
//  NetworkServiceTests.swift
//  RestaurantDomainTests
//
//  Created by Guilherme Prata Costa on 31/03/23.
//

import XCTest
@testable import RestaurantDomain

final class NetworkServiceTests: XCTestCase {
    func test_request_and_resume_dataTask_with_url() throws {
        let (sut, Doubles) = makeSUT()
        Doubles.session.stub(with: Doubles.anyURL, task: Doubles.task)
        
        sut.request(from: Doubles.anyURL) { _ in }
                
        XCTAssertEqual(Doubles.task.resumeCont, 1)
    }
    
    func test_request_and_completion_with_error_for_invalidCases() throws{
        let url = URL(string: "https://comitando.com.br")!

        let anyError = NSError(domain: "any error", code: -1)
        let _ = assert(url: url, data: nil, response: nil, error: anyError)
        let httpResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        let urlResponse = URLResponse(url: url, mimeType: nil, expectedContentLength: 1, textEncodingName: nil)
        let data = Data()

        XCTAssertNotNil(resultErrorForInvalidCases(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorForInvalidCases(data: nil, response: urlResponse, error: nil))
        XCTAssertNotNil(resultErrorForInvalidCases(data: nil, response: httpResponse, error: nil))
        XCTAssertNotNil(resultErrorForInvalidCases(data: data, response: nil, error: nil))
        XCTAssertNotNil(resultErrorForInvalidCases(data: data, response: nil, error: anyError))
        XCTAssertNotNil(resultErrorForInvalidCases(data: nil, response: urlResponse, error: anyError))
        XCTAssertNotNil(resultErrorForInvalidCases(data: nil, response: httpResponse, error: anyError))
        XCTAssertNotNil(resultErrorForInvalidCases(data: data, response: urlResponse, error: anyError))
        XCTAssertNotNil(resultErrorForInvalidCases(data: data, response: httpResponse, error: anyError))
        XCTAssertNotNil(resultErrorForInvalidCases(data: nil, response: nil, error: anyError))
        
        let result = resultErrorForInvalidCases(data: nil, response: nil, error: anyError)
        XCTAssertEqual(result as? NSError, anyError)

    }
    
    func test_request_and_completion_with_sucess_for_valid_cases() throws{
        let url = URL(string: "https://comitando.com.br")!
        let data = Data()
        let okResponse = 200
        let response = HTTPURLResponse(url: url, statusCode: okResponse, httpVersion: nil, headerFields: nil)
        
        XCTAssertNotNil(resultSucessForValidCases(data: data, response: response, error: nil))
        
        let result = resultSucessForValidCases(data: data, response: response, error: nil)
        
        XCTAssertEqual(result?.data, data)
        XCTAssertEqual(result?.response.url, url)
        XCTAssertEqual(result?.response.statusCode, response?.statusCode)


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
    
    private func assert(
        url: URL,
        data: Data?,
        response: URLResponse?,
        error: Error?,
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> NetworkService.NetworkResult? {

        let (sut, Doubles) = makeSUT()
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
    
    func resultErrorForInvalidCases(data: Data?,
                                    response: URLResponse?,
                                    error: Error?,
                                    file: StaticString = #filePath,
                                    line: UInt = #line) -> Error? {
        let url = URL(string: "https://comitando.com.br")!

        let result = assert(url: url, data: data, response: response, error: error)
        
        switch result {
        case let .failure(returnedError):
            return returnedError
        default:
            XCTFail("Esperando falha mas retorno \(String(describing: result))")
        }
        
        return nil
    }
    
    func resultSucessForValidCases(data: Data?,
                                   response: URLResponse?,
                                   error: Error?,
                                   file: StaticString = #filePath,
                                   line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
        let url = URL(string: "https://comitando.com.br")!

        let result = assert(url: url, data: data, response: response, error: error)
        
        switch result {
        case let .success((returnedData, returnedResponse)):
            return (returnedData, returnedResponse)
        default:
            XCTFail("Esperando sucesso mas retorno \(String(describing: result))")
        }
        
        return nil
    }
    
}
