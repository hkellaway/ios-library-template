//
 //
 //  NetworkingTests.swift
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

import XCTest
@testable import LibraryTemplate

class NetworkingTests: XCTestCase {
    var sut: Networking!
    var mockURLSession: MockURLSession<MockModel>!
    
    override func setUp() {
        super.setUp()
        
        self.mockURLSession = MockURLSession<MockModel>()
        self.sut = Networking(baseUrl: "api.github.com", urlSession: self.mockURLSession)
    }
    
    func test_makeUrl_withValidPath_isSuccess() {
        let urlRequest = self.sut.makeUrlRequest(request: NetworkRequest(
            path: "/zen",
            httpMethod: .GET)
        )
        XCTAssertEqual(try! urlRequest.get().url!.absoluteString, "https://api.github.com/zen")
    }
    
    func test_makeUrl_withValidPath_andParams_isSuccess() {
        let urlRequest = self.sut.makeUrlRequest(request: NetworkRequest(
            path: "/zen",
            parameters: ["some": "param"],
            httpMethod: .GET)
        )
        XCTAssertEqual(try! urlRequest.get().url!.absoluteString, "https://api.github.com/zen?some=param")
    }
    
    func test_makeUrl_withInvalidParams_isFailure() {
        var isFailure = false
        if case .failure = self.sut.makeUrlRequest(
            request: NetworkRequest(path: "zen", parameters: nil, httpMethod: .GET)) {
            isFailure = true
        }
        XCTAssertTrue(isFailure)
    }
    
    func test_get_defaultsSchemeToHTTPS() {
        let expectation = XCTestExpectation()
        sut.get(model: MockModel.self, request: NetworkRequest(path: "/zen",
                                                               httpMethod: .GET)) { _ in
            expectation.fulfill()
        }
        
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 2 / 1000.0), .completed)
        XCTAssertEqual(mockURLSession.lastTask?.url.absoluteString, "https://api.github.com/zen")
    }
    
    func test_get_withValidData_isSuccess() {
        mockURLSession.result = {
            return (try? JSONSerialization.data(withJSONObject: ["id" : 123]),
                    nil, nil)
        }

        let expectation = XCTestExpectation()
        var actual: Result<MockModel, NetworkingError>?
        sut.get(model: MockModel.self, request: NetworkRequest(path: "/zen",
                                                               httpMethod: .GET)) {
            actual = $0
            expectation.fulfill()
        }
        
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 2 / 1000.0), .completed)
        XCTAssertEqual(try! actual?.get(), MockModel(id: 123))
    }
    
    func test_get_withError_isFailure() {
        mockURLSession.result = {
            return (nil, nil, NetworkingError.noData)
        }

        let expectation = XCTestExpectation()
        var actual: Result<MockModel, NetworkingError>? = .success(MockModel(id: 456))
        sut.get(model: MockModel.self, request: NetworkRequest(path: "/zen",
                                                               httpMethod: .GET)) {
            actual = $0
            expectation.fulfill()
        }
        
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 2 / 1000.0), .completed)
        XCTAssertNil(try? actual?.get())
    }

}
