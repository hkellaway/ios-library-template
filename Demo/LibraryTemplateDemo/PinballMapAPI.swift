//
//
//  PinballMapAPI.swift
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

import Foundation
import LibraryTemplate
import SwiftUI

struct LocationList: Decodable, Equatable {
    let locations: [Location]
}

extension LocationList {
    private enum CodingKeys: String, CodingKey {
        case locations, userFaveLocations
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let locations = try? container.decode([Location].self, forKey: .locations)
        let userFaveLocations = try? container.decode([UserFaveLocation].self, forKey: .userFaveLocations)
        
        guard let locations: [Location] = locations ?? userFaveLocations else {
            throw DecodingError.typeMismatch(Location.self, DecodingError.Context(
                codingPath: [CodingKeys.locations, CodingKeys.userFaveLocations],
                debugDescription: "Could not decode `LocationList`.")
            )
        }
        
        self.init(locations: locations)
    }
}

final class UserFaveLocation: Location {
    let favoriteId: Int
    let userId: Int
    let locationId: Int
    
    init(wrapped location: Location, favoriteId: Int, userId: Int, locationId: Int) {
        self.favoriteId = favoriteId
        self.userId = userId
        self.locationId = locationId
        super.init(id: location.id, name: location.name)
    }
    
    // MARK: Decodable
    
    private enum CodingKeys: String, CodingKey {
        case favoriteId = "id", userId, locationId, location
    }
    
    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let location = try container.decode(Location.self, forKey: .location)
        let favoriteId = try container.decode(Int.self, forKey: .favoriteId)
        let userId = try container.decode(Int.self, forKey: .userId)
        let locationId = try container.decode(Int.self, forKey: .locationId)
        self.init(wrapped: location, favoriteId: favoriteId, userId: userId, locationId: locationId)
    }
}

class Location: Comparable, Decodable, Equatable, Identifiable {
    private(set) var id: Int!
    private(set) var name: String!
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
    
    // MARK: Decodable
    
    private enum CodingKeys: String, CodingKey {
        case id, name
    }
    
    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(Int.self, forKey: .id)
        let name = try container.decode(String.self, forKey: .name)
        self.init(id: id, name: name)
    }
}

extension Location {
    static func <(lhs: Location, rhs: Location) -> Bool {
        return lhs.name < rhs.name
    }
}

extension Location {
    static func ==(lhs: Location, rhs: Location) -> Bool {
        return lhs.id == rhs.id
    }
}

struct RegionList: Decodable, Equatable {
    let regions: [Region]
}

struct Region: Comparable, Decodable, Equatable, Identifiable {
    let id: Int
    let name: String
    let fullName: String
}

extension Region {
    static func <(lhs: Region, rhs: Region) -> Bool {
        return lhs.name < rhs.name
    }
}

extension Region {
    private enum CodingKeys: String, CodingKey {
        case id, name, fullName
        case region // used when nested
    }
    
    init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<CodingKeys>
        
        // When a region is returned solo, it's as a nested container keyed by `region`
        let topLevelContainer = try decoder.container(keyedBy: CodingKeys.self)
        if let nestedContainer = try? topLevelContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .region) {
            container = nestedContainer
        } else {
            // However, region properties can also be returned unnested, such as in a list
           container = topLevelContainer
        }
        
        // Either way, the properties are the same
        let id = try container.decode(Int.self, forKey: .id)
        let name = try container.decode(String.self, forKey: .name)
        let fullName = try container.decode(String.self, forKey: .fullName)
        self.init(id: id, name: name, fullName: fullName)
    }
}

struct User: Decodable, Equatable, Identifiable {
    let id: Int
    let username: String
    let email: String
    let authenticationToken: String
}

extension User {
    private enum CodingKeys: String, CodingKey {
        case id, username, email, authenticationToken
        case user // used when nested
    }
    
    init(from decoder: Decoder) throws {
        let topLevelContainer = try decoder.container(keyedBy: CodingKeys.self)
        let container = try topLevelContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .user)
        let id = try container.decode(Int.self, forKey: .id)
        let username = try container.decode(String.self, forKey: .username)
        let email = try container.decode(String.self, forKey: .email)
        let authenticationToken = try container.decode(String.self, forKey: .authenticationToken)
        self.init(id: id, username: username, email: email, authenticationToken: authenticationToken)
    }
}

struct UserSubmission: Decodable, Equatable, Identifiable {
    // TODO: Make Comparable by updatedAt
    
    enum SubmissionType: Decodable {
        case confirmLocation,
             contactUs,
             deleteLocation,
             locationMetadata,
             newCondition,
             newLmx,
             newMsx,
             removeMachine,
             suggestLocation
    }
    
    let id: Int
    let regionId: Int
    let submissionType: SubmissionType
    let submission: String
}

struct Zone: Comparable, Decodable, Equatable, Identifiable {
    let id: Int
    let regionId: Int
    let name: String
}

extension Zone {
    static func <(lhs: Zone, rhs: Zone) -> Bool {
        return lhs.name < rhs.name
    }
}

final class PinballMapAPI: Networking, ExpressibleByIntegerLiteral {
    public private(set) var version: Int!
    
    convenience init(integerLiteral value: IntegerLiteralType) {
        precondition(value == 1, "Only v1 supported")
        
        self.init(baseUrl: "pinballmap.com", jsonDecoder: .makeSnakeCase())!
        self.version = value
    }
    
    override func makeUrlRequest(request: NetworkRequest) -> Result<URLRequest, NetworkingError> {
        super.makeUrlRequest(
            request: NetworkRequest(path: "/api/v\(self.version!)/\(request.path).json",
                                    parameters: request.parameters,
                                    httpMethod: request.httpMethod)
        )
    }
}


// MARK: - Schema

extension NetworkRequest {
    // MARK: Events
    
    static func events(region regionName: String) -> NetworkRequest { .init(
        namespace: .region,
        path: "\(regionName)/\(Namespace.events.rawValue)",
        httpMethod: .GET
    )}
    
    // MARK: Locations
    
    // TODO: Request can take other params
    static func locations(region regionName: String) -> NetworkRequest { .init(
        namespace: .region,
        path: "\(regionName)/\(Namespace.locations.rawValue)",
        httpMethod: .GET
    )}
    
    // MARK: Regions
    
    // TODO: Request can take other params
    static func closestRegionBy(lat: String, lon: String) -> NetworkRequest { .init(
        namespace: .regions,
        path: "closest_by_lat_lon",
        parameters: ["lat": lat, "lon": lon],
        httpMethod: .GET
    )}
    static func doesRegionExist(name: String) -> NetworkRequest { .init(
        namespace: .regions,
        path: "does_region_exist",
        parameters: ["name": name],
        httpMethod: .GET
    )}
    static let regions: NetworkRequest = .init(
        namespace: .regions,
        path: nil,
        httpMethod: .GET
    )
    
    // MARK: Users
    
    static func addFaveLocation(user: User, locationId: Int) -> NetworkRequest { .init(
        namespace: .users,
        path: "\(user.id)/add_fave_location",
        parameters: ["location_id": String(locationId)],
        httpMethod: .POST
    ).authenticated(user: user)}
    static func authDetails(login: String, password: String) -> NetworkRequest { .init(
        namespace: .users,
        path: "auth_details",
        parameters: ["login": login, "password": password],
        httpMethod: .GET
    )}
    static func listFaveLocations(userId: Int) -> NetworkRequest { .init(
        namespace: .users,
        path: "\(userId)/list_fave_locations",
        httpMethod: .GET
    )}
    
    // MARK: User Submissions
    
    static func userSubmissions(region regionName: String) -> NetworkRequest { .init(
        namespace: .region,
        path: "\(regionName)/\(Namespace.userSubmissions.rawValue)",
        httpMethod: .GET
    )}
    
    // MARK: Zones
    
    static func zones(region regionName: String) -> NetworkRequest { .init(
        namespace: .region,
        path: "\(regionName)/\(Namespace.zones.rawValue)",
        httpMethod: .GET
    )}
    
    private func authenticated(user: User) -> NetworkRequest {
        let authParams: Parameters = [
            "user_email": user.email,
            "user_token": user.authenticationToken
        ]
        return NetworkRequest(path: self.path,
                              parameters: (self.parameters ?? [:]).merging(
                                authParams,
                                uniquingKeysWith: { (old, _) in old }
                              ),
                              httpMethod: self.httpMethod)
    }
}

extension NetworkRequest {
    fileprivate enum Namespace: String {
        case events
        case locations
        case region
        case regions
        case users
        case userSubmissions
        case zones
    }
    
    fileprivate init(namespace: Namespace,
                     path: String?,
                     parameters: [String: String]? = nil,
                     httpMethod: HTTPMethod) {
        let fullPath = path.flatMap { "/\($0)" } ?? ""
        self.init(path: "\(namespace.rawValue)\(fullPath)", parameters: parameters, httpMethod: httpMethod)
    }
}

extension Bool {
    func toString() -> String {
        return self == true ? "true" : "false"
    }
}
