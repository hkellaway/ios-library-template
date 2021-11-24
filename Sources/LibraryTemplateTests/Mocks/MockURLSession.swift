//
 //
 //  MockURLSession.swift
 //  LibraryTemplate
 //
 // Copyright (c) 2021
 //
 // Permission is hereby granted, free of charge, to any person obtaining a copy
 // of this software and associated documentation files (the "Software"), to deal
 // in the Software without restriction, including without limitation the rights
 // to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 // copies of the Software, and to permit persons to whom the Software is
 // furnished to do so, subject to the following conditions:
 //
 // The above copyright notice and this permission notice shall be included in
 // all copies or substantial portions of the Software.
 //
 // THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 // IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 // FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 // AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 // LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 // OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 // THE SOFTWARE.
 //
 //

import Foundation

class MockURLSessionDataTask: URLSessionDataTask {
    let url: URL
    var resumeHandler: () -> Void = { preconditionFailure("Set `resumeHandler` to use.") }
    
    init(url: URL) {
        self.url = url
    }
    
    override func resume() {
        resumeHandler()
    }
}

class MockURLSession<T: Decodable>: URLSession {
    var result: () -> ((Data?, URLResponse?, Error?)) = { return (nil, nil, nil) }
    private(set) var lastTask: MockURLSessionDataTask?
    
    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let result = self.result()
        let task = MockURLSessionDataTask(url: request.url!)
        task.resumeHandler = { completionHandler(result.0, result.1, result.2) }
        self.lastTask = task
        return task
    }
}
