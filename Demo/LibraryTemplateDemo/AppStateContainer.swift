//
//
//  AppStateContainer.swift
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

import CoreLocation
import LibraryTemplate
import SwiftUI

private let kUsername = "pintist"
private let kPassword = "LxGLscQsa9BT"

struct RootView: View {
    @EnvironmentObject var appState: AppStateContainer
    
    var body: some View {
        Group {
            if let currentUser = self.appState.currentUser.value {
                NavigationView {
                    ContentView(currentUser: currentUser)
                        .navigationTitle("Pinball Map")
                        .navigationBarTitleDisplayMode(.inline)
                }
            } else {
                Text("Authenticating...")
            }
        }.onAppear(perform: {
            self.appState.requestLocationAuthorizationIfNeeded()
            self.appState.login(username: kUsername, password: kPassword)
        })
    }
}

final class AppStateContainer: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published private(set) var regionList: RemoteData<RegionList> = .undefined
    @Published private(set) var lastCheckedRegion: RemoteData<Region> = .undefined
    @Published private(set) var lastCheckedLocations: RemoteData<LocationList> = .undefined
    @Published private(set) var userFaveLocations: RemoteData<LocationList> = .undefined
    @Published private(set) var lastFavedLocation: RemoteData<UserFaveLocation> = .undefined
    @Published private(set) var locationAuthStatus: CLAuthorizationStatus = .notDetermined
    
    @Published fileprivate var currentUser: RemoteData<User> = .undefined
    
    private var authToken: String? {
        return self.currentUser.value?.authenticationToken
    }
    
    private let api: PinballMapAPI
    private let locationManager: CLLocationManager
    
    init(apiVersion api: PinballMapAPI, locationManager: CLLocationManager = CLLocationManager()) {
        self.api = api
        self.locationManager = locationManager
        super.init()
        
        locationManager.delegate = self
    }
    
    // MARK: - Local state
    
    func logout() {
        self.currentUser = .undefined
    }
    
    // MARK: - LocationServices
    
    func requestLocationAuthorizationIfNeeded() {
        self.locationManager.requestAlwaysAuthorization()
    }
    
    // MARK: - PinballMap API
    
    // MARK: Auth
    
    func login(username: String, password: String) {
        self.request(request: .authDetails(login: username, password: password),
                     keypath: \.currentUser)
    }
    
    // MARK: User
    
    func getFaveLocations() {
        guard let currentUser = self.currentUser.value else {
            assertionFailure("Unexpected state.")
            return
        }
        
        self.request(request: .listFaveLocations(userId: currentUser.id),
                     keypath: \.userFaveLocations)
    }
    
    func addFaveLocation(id locationId: Int) {
        guard let currentUser = self.currentUser.value else {
            assertionFailure("Unexpected state.")
            return
        }
        
        self.request(request: .addFaveLocation(
            user: currentUser,
            locationId: locationId
        ), keypath: \.lastFavedLocation)
    }
    
    // MARK: Locations
    
    func getLocationsForRegion(named name: String) {
        self.request(request: .locations(region: name),
                     keypath: \.lastCheckedLocations)
    }   
    
    // MARK: Regions
    
    func getRegions() {
        self.request(request: .regions, keypath: \.regionList)
    }
    
    func getClosestRegionTo(coordinate: CLLocationCoordinate2D) {
        self.request(request: .closestRegionBy(lat: String(coordinate.latitude), lon: String(coordinate.longitude)),
                     keypath: \.lastCheckedRegion)
    }
    
    func doesRegionExist(named name: String) { 
        self.request(request: .doesRegionExist(name: name), keypath: \.lastCheckedRegion)
    }
    
    // MARK: Utility
    
    func isLocationFavorite(_ location: Location) -> Bool {
        return ((self.userFaveLocations.value?.locations ?? [])
                    .contains(where: { $0 == location }))
    }
    
    // MARK: Private
    
    private func request<T: Decodable>(request: NetworkRequest,
                                       keypath: ReferenceWritableKeyPath<AppStateContainer, RemoteData<T>>) {
        func stateChange(_ value: RemoteData<T>) {
            self[keyPath: keypath] = value
        }
        
        stateChange(.loading)
        
        self.api.get(model: T.self, request: request) { [weak self] result in
            guard let _ = self else { return }
            
            DispatchQueue.main.async {
                stateChange(.fromNetworkRequest(result))
            }
        }
    }
}

// MARK: - Protocol conformance

// MARK: CLLocationManagerDelegate

extension AppStateContainer {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.locationAuthStatus = manager.authorizationStatus
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        (manager.location?.coordinate).flatMap(self.getClosestRegionTo)
    }
}

enum RemoteData<T: Decodable> {
    case undefined
    case loading
    case loaded(model: T)
    case errored(error: NetworkingError)
    
    var value: T? {
        switch self {
        case .loaded(let model):
            return model
        case .undefined, .loading, .errored:
            return nil
        }
    }
    
    static func fromNetworkRequest(_ requestResult: Result<T, NetworkingError>) -> RemoteData<T> {
        switch requestResult {
        case .success(let model):
            return .loaded(model: model)
        case .failure(let error):
            return .errored(error: error)
        }
    }
}

extension CLAuthorizationStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .authorizedAlways:
            return "Authorized Always"
        case .authorizedWhenInUse:
            return "Authorized When in Use"
        case .denied:
            return "Deined"
        case .notDetermined:
            return "Not Determined"
        case .restricted:
            return "Restricted"
        @unknown default:
            return "Unknown"
        }
    }
}
