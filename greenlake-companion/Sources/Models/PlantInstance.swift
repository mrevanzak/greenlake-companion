//
//  PlantInstance.swift
//  greenlake-companion
//
//  Created by AI Assistant on 28/08/25.
//

import CoreLocation
import Foundation

/// Strongly-typed category for plants used by UI pickers and map styling
enum PlantType: String, CaseIterable, Identifiable, Codable, Hashable {
  case tree
  case groundCover
  case bush

  var id: String { rawValue }

  /// Human readable display name
  var displayName: String {
    switch self {
    case .tree: return "Tree"
    case .groundCover: return "Ground Cover"
    case .bush: return "Bush"
    }
  }
}

/// Value-type domain model representing a plant on the map
struct PlantInstance: Identifiable, Hashable, Codable {
  let id: UUID
  var type: PlantType
  var name: String?
  var location: CLLocationCoordinate2D
  var createdAt: Date
  var updatedAt: Date?

  /// Tree radius in meters - only applicable for trees
  var radius: Double?

  init(
    id: UUID = UUID(),
    location: CLLocationCoordinate2D,
    name: String? = nil,
    type: PlantType = .tree,
    createdAt: Date = Date(),
    radius: Double? = nil
  ) {
    self.id = id
    self.location = location
    self.name = name
    self.type = type
    self.createdAt = createdAt

    switch type {
    case .tree:
      self.radius = radius
    case .groundCover, .bush:
      self.radius = nil
    }
  }
}

// MARK: - Codable

extension PlantInstance {
  private enum CodingKeys: String, CodingKey {
    case id
    case latitude
    case longitude
    case name
    case type
    case createdAt
    case radius
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let id = try container.decode(UUID.self, forKey: .id)
    let latitude = try container.decode(CLLocationDegrees.self, forKey: .latitude)
    let longitude = try container.decode(CLLocationDegrees.self, forKey: .longitude)
    let name = try container.decodeIfPresent(String.self, forKey: .name)
    let type = try container.decode(PlantType.self, forKey: .type)
    let createdAt = try container.decode(Date.self, forKey: .createdAt)
    let radius = try container.decodeIfPresent(Double.self, forKey: .radius)

    self.init(
      id: id,
      location: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
      name: name,
      type: type,
      createdAt: createdAt,
      radius: radius
    )
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(id, forKey: .id)
    try container.encode(location.latitude, forKey: .latitude)
    try container.encode(location.longitude, forKey: .longitude)
    try container.encodeIfPresent(name, forKey: .name)
    try container.encode(type, forKey: .type)
    try container.encode(createdAt, forKey: .createdAt)
    try container.encodeIfPresent(radius, forKey: .radius)
  }
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
