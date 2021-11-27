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

import CoreLocation
import LibraryTemplate
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppStateContainer
    
    let currentUser: User
    
    private let regionToCheck = "nyc"
    private let locationToFave = 2577 // B61
    
    var body: some View {
        VStack {
            Text("Hello, \(self.currentUser.username) (\(self.currentUser.id))!")
            switch appState.regionList {
            case .undefined, .loading:
                Text("Loading...")
            case .errored(let error):
                Text(error.localizedDescription)
            case .loaded(let regionList):
                let letter = "n"
                let filtered = regionList.regions.filter { $0.name.lowercased().hasPrefix(letter) }
                VStack {
                    if let lastRegionChecked = self.appState.lastCheckedRegion.value {
                        Text("Last region checked: \(lastRegionChecked.name)")
                    } else {
                        Text("Last region checked: undefined")
                    }
                    Text("Location Auth Status: \(self.appState.locationAuthStatus.description)")
                    Text("\(regionList.regions.count) Regions")
                        .font(.title)
                    Text("Filtered by letter: \(letter)")
                        .font(.title2)
                    Button("Add fave: \(self.regionToCheck)", action: {
                        self.appState.addFaveLocation(id: self.locationToFave)
                    })
                    List(filtered.sorted()) { region in
                        NavigationLink(destination: {
                            RegionDetailView(region: region).environmentObject(self.appState)
                        }, label: {
                            Text(region.fullName.capitalized)
                                .background(self.appState.lastCheckedRegion.value == region ? Color.yellow : Color.white)
                        })
                    }
                }
            }
        }.onAppear(perform: {
            self.appState.getRegions()
        })
    }
}

struct RegionDetailView: View {
    @EnvironmentObject var appState: AppStateContainer
    
    let region: Region
    
    var body: some View {
        VStack {
            if let locations = self.appState.lastCheckedLocations.value,
               let _ = self.appState.userFaveLocations {
                List(locations.locations.sorted()) { location in
                    Text("\(location.name) (\(location.id))")
                        .background(self.appState.isLocationFavorite(location) ? Color.green : Color.white)
                }
            } else {
                Text("Loading...")
            }
        }
        .navigationTitle(self.region.fullName.capitalized)
        .onAppear(perform: {
            self.appState.getLocationsForRegion(named: self.region.name)
            self.appState.getFaveLocations()
        })
    }
}
