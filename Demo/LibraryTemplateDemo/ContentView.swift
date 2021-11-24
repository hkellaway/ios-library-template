//
//
//  ContentView.swift
//  LibraryTemplateDemo
//
// Copyright (c) 2021 Harlan Kellaway
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

import LibraryTemplate
import SwiftUI

struct ToDo: Codable {
    let id: Int
    let title: String
    let completed: Bool
}

enum RemoteData<T: Decodable> {
    case loading
    case loaded(model: T)
    case errored(error: NetworkingError)
    
    static func fromNetworkRequest(_ requestResult: Result<T, NetworkingError>) -> RemoteData<T> {
        switch requestResult {
        case .success(let model):
            return .loaded(model: model)
        case .failure(let error):
            return .errored(error: error)
        }
    }
}

class PlaceholderAPI: ObservableObject {
    @Published var data: RemoteData<ToDo> = .loading
    
    let networking: Networking
    
    init?() {
        guard let networking = Networking(baseUrl: "jsonplaceholder.typicode.com") else {
            return nil
        }
        self.networking = networking
    }
    
    func load() {
        self.networking.get(model: ToDo.self, path: "/todos/1") { [weak self] result in
            DispatchQueue.main.async {
                self?.data = .fromNetworkRequest(result)
            }
        }
    }
}

struct ContentView: View {
    @ObservedObject private(set) var api = PlaceholderAPI()!
    
    var text: String {
        switch api.data {
        case .loading: return "Loading..."
        case .loaded(let model): return model.title
        case .errored(let error): return error.localizedDescription
        }
    }
    
    var body: some View {
        Text(self.text)
            .onAppear(perform: api.load)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
