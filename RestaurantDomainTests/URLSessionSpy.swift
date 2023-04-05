//
//  URLSessionSpy.swift
//  RestaurantDomainTests
//
//  Created by Guilherme Prata Costa on 05/04/23.
//

import Foundation

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
        
        completionHandler(stub.data, stub.response, stub.error)
        return stub.task
    }
    
    func stub(with url: URL, task: URLSessionDataTask, data: Data? = nil, response: URLResponse? = nil, error: Error? = nil) {
        stubs[url] = Stub(task: task, data: data, response: response, error: error)
    }
}
