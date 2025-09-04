//
//  PlantInstance.swift
//  greenlake-companion
//
//  Created by AI Assistant on 28/08/25.
//

import CoreLocation
import Foundation

/// Strongly-typed category for plants used by UI pickers and map styling
enum PlantType: String, CaseIterable, Identifiable, Codable, Hashable, DisplayableParameter {
  case tree = "tree"
  case groundCover = "ground_cover"
  case bush = "bush"

  var id: String { self.rawValue }

  /// Human readable display name
  var displayName: String {
    switch self {
    case .tree: return "Pohon"
    case .groundCover: return "Ground Cover"
    case .bush: return "Semak"
    }
  }
}

/// Value-type domain model representing a plant on the map
struct PlantInstance: Identifiable, Hashable, Codable {
  let id: UUID
  var type: PlantType
  var name: String
  var location: CLLocationCoordinate2D
  var createdAt: Date
  var updatedAt: Date

  // Tree specific properties
  var radius: Double?

  // Path specific properties
  var path: [CLLocationCoordinate2D]?

  init(
    id: UUID = UUID(),
    type: PlantType,
    name: String,
    location: CLLocationCoordinate2D,
    radius: Double? = nil,
    path: [CLLocationCoordinate2D]? = nil,
    createdAt: Date,
    updatedAt: Date
  ) {
    self.id = id
    self.type = type
    self.name = name
    self.location = location
    self.createdAt = createdAt
    self.updatedAt = updatedAt

    switch type {
    case .tree:
      self.radius = radius
      self.path = nil
    case .groundCover, .bush:
      self.radius = nil
      self.path = path
    }
  }

  static func empty() -> PlantInstance {
    return PlantInstance(
      type: .tree, name: "Pinus",
      location: CLLocationCoordinate2D(latitude: 0, longitude: 0),
      radius: 0,
      createdAt: Date(),
      updatedAt: Date())
  }
}

// MARK: - Codable

extension PlantInstance {
  private enum CodingKeys: String, CodingKey {
    case id
    case type
    case name
    case location
    case radius
    case path
    case createdAt
    case updatedAt
  }

  private enum LocationKeys: String, CodingKey {
    case lat
    case lng
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    // Decode ID as string first, then convert to UUID
    let idString = try container.decode(String.self, forKey: .id)
    guard let id = UUID(uuidString: idString) else {
      throw DecodingError.dataCorruptedError(
        forKey: .id,
        in: container,
        debugDescription: "Invalid UUID string: \(idString)"
      )
    }
    let type = try container.decode(PlantType.self, forKey: .type)
    let name = try container.decode(String.self, forKey: .name)

    // Decode nested location object
    let locationContainer = try container.nestedContainer(
      keyedBy: LocationKeys.self, forKey: .location)
    let latitude = try locationContainer.decode(CLLocationDegrees.self, forKey: .lat)
    let longitude = try locationContainer.decode(CLLocationDegrees.self, forKey: .lng)
    let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

    let radius = try container.decodeIfPresent(Double.self, forKey: .radius)

    // Decode path array if present
    var path: [CLLocationCoordinate2D]? = nil
    if let pathArray = try container.decodeIfPresent([PathCoordinate].self, forKey: .path) {
      path = pathArray.map { pathCoordinate in
        CLLocationCoordinate2D(latitude: pathCoordinate.lat, longitude: pathCoordinate.lng)
      }
    }

    let createdAt = try container.decode(Date.self, forKey: .createdAt)
    let updatedAt = try container.decode(Date.self, forKey: .updatedAt)

    self.init(
      id: id,
      type: type,
      name: name,
      location: location,
      radius: radius,
      path: path,
      createdAt: createdAt,
      updatedAt: updatedAt
    )
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    try container.encode(id, forKey: .id)
    try container.encode(type, forKey: .type)
    try container.encode(name, forKey: .name)

    // Encode nested location object
    var locationContainer = container.nestedContainer(keyedBy: LocationKeys.self, forKey: .location)
    try locationContainer.encode(location.latitude, forKey: .lat)
    try locationContainer.encode(location.longitude, forKey: .lng)

    try container.encodeIfPresent(radius, forKey: .radius)

    // Encode path array if present
    if let path = path {
      let pathArray = path.map { coordinate in
        PathCoordinate(lat: coordinate.latitude, lng: coordinate.longitude)
      }
      try container.encode(pathArray, forKey: .path)
    }

    try container.encode(createdAt, forKey: .createdAt)
    try container.encode(updatedAt, forKey: .updatedAt)
  }
}

// MARK: - Helper Types

struct PathCoordinate: Codable {
  let lat: CLLocationDegrees
  let lng: CLLocationDegrees
}

// MARK: - Equatable & Hashable

extension PlantInstance {
  static func == (lhs: PlantInstance, rhs: PlantInstance) -> Bool {
    lhs.id == rhs.id
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

// MARK: - Spread-like Updates

extension PlantInstance {
  /// Create a new instance with updated properties (similar to JavaScript spread operator)
  func with(
    name: String? = nil,
    type: PlantType? = nil,
    location: CLLocationCoordinate2D? = nil,
    radius: Double? = nil,
    path: [CLLocationCoordinate2D]? = nil
  ) -> PlantInstance {
    PlantInstance(
      id: self.id,
      type: type ?? self.type,
      name: name ?? self.name,
      location: location ?? self.location,
      radius: radius ?? self.radius,
      path: path ?? self.path,
      createdAt: self.createdAt,
      updatedAt: Date()
    )
  }
}
