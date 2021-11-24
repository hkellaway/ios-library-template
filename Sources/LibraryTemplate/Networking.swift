//
 //
 //  Networking.swift
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

extension JSONDecoder {
    public static func makeSnakeCase() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}

public struct HTTPMethod {
    public static let GET = HTTPMethod(rawValue: "GET")
    public static let POST = HTTPMethod(rawValue: "POST")
    
    fileprivate let rawValue: String
}
    
public struct NetworkRequest {
    public typealias Parameters = [String: String]
    
    public let path: String
    public let parameters: [String: String]?
    public let httpMethod: HTTPMethod
    
    public init(path: String, parameters: [String: String]? = nil, httpMethod: HTTPMethod) {
        self.path = path
        self.parameters = parameters
        self.httpMethod = httpMethod
    }
}

extension NetworkRequest.Parameters {
    public func toQueryItems() -> [URLQueryItem] {
        return self.map { URLQueryItem(name: $0.key, value: $0.value) }
    }
}

open class Networking {
    public let baseUrl: URL
    public let scheme: String
    public let urlSession: URLSession
    public let jsonDecoder: JSONDecoder
    
    public var host: String {
        return self.baseUrl.absoluteString
    }
    
    public init?(baseUrl: String,
                 scheme: String = "https",
                 jsonDecoder: JSONDecoder = JSONDecoder(),
                 urlSession: URLSession = .shared) {
        guard let url = URL(string: baseUrl) else {
            return nil
        }
        self.baseUrl = url
        self.scheme = scheme
        self.urlSession = urlSession
        self.jsonDecoder = jsonDecoder
    }
    
    open func get<T: Decodable>(model: T.Type,
                                request: NetworkRequest,
                                completion: @escaping (Result<T, NetworkingError>) -> ()) {
        switch self.makeUrlRequest(request: request) {
        case .success(let urlRequest):
            self.urlSession.dataTask(with: urlRequest) { completion(self.decodeModel(($0, $2))) }.resume()
        case .failure(let error):
            completion(.failure(error))
        }
    }
    
    open func decodeModel<T: Decodable>(_ requestResponse: (Data?, Error?)) -> Result<T, NetworkingError> {
        if let error = requestResponse.1 {
            return .failure(.requestError(value: error))
        }
        
        return requestResponse.0.flatMap { data in
            return Result { try self.jsonDecoder.decode(T.self, from: data) }
                .mapError(NetworkingError.requestError)
        } ?? .failure(.noData)
    }
    
    open func makeUrlRequest(request: NetworkRequest) -> Result<URLRequest, NetworkingError> {
        var components = URLComponents()
        components.scheme = scheme
        components.host = self.host.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        components.path = request.path.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? request.path
        components.queryItems = request.parameters?.toQueryItems()
        return components.url.flatMap {
            var urlRequest = URLRequest(url: $0)
            urlRequest.httpMethod = request.httpMethod.rawValue
            return .success(urlRequest)
        } ?? .failure(.invalidUrl(scheme: self.scheme, host: self.host, path: request.path))
    }
}

public enum NetworkingError: Error, LocalizedError {
    case invalidUrl(scheme: String, host: String, path: String)
    case requestError(value: Error)
    case noData
    
    public var errorDescription: String? {
        switch self {
        case .invalidUrl(let scheme, let host, let path):
            return """
            Invalid URL. scheme = \(scheme);
            host = \(host); path = \(path)
            """
        case .requestError(let value):
            return value.localizedDescription
        case .noData:
            return "No data returned from request."
        }
    }
}
