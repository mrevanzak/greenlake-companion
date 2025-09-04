//
//  NetworkResponse.swift
//  greenlake-companion
//
//  Created by AI Assistant on 28/08/25.
//

import CoreLocation
import Foundation

/// Generic API response wrapper
struct APIResponse<T: Codable>: Codable {
  let success: Bool
  let message: String
  let data: T
}

/// Response for operations that don't return data (e.g., delete operations)
struct MessageOnlyResponse: Codable {
  let success: Bool
  let message: String
}

/// Specific response for plants endpoint
typealias PlantsResponse = APIResponse<[PlantInstance]>

/// Specific response for single plant endpoint
typealias PlantResponse = APIResponse<PlantInstance>

/// Specific response for tasks endpoint
typealias TasksAPIResponse = APIResponse<[TaskResponse]>

/// Specific response for single task endpoint
typealias TaskAPIResponse = APIResponse<TaskResponse>

/// API error response structure
struct APIError: Codable, LocalizedError {
  let code: String
  let message: String
  let details: [String: String]?

  var errorDescription: String? {
    message
  }
}

/// Pagination metadata for list responses
struct PaginationMeta: Codable {
  let page: Int
  let limit: Int
  let total: Int
  let totalPages: Int

  enum CodingKeys: String, CodingKey {
    case page
    case limit
    case total
    case totalPages = "total_pages"
  }
}

/// Paginated API response for list endpoints
struct PaginatedResponse<T: Codable>: Codable {
  let data: [T]
  let meta: PaginationMeta
}

/// Plant update request model for API calls
struct PlantUpdateRequest: Codable {
  let name: String?
  let type: PlantType
  let radius: Double?
  let path: [CLLocationCoordinate2D]?

  enum CodingKeys: String, CodingKey {
    case name
    case type
    case radius
    case path
  }

  init(name: String?, type: PlantType, radius: Double?, path: [CLLocationCoordinate2D]? = nil) {
    self.name = name
    self.type = type
    self.radius = radius
    self.path = path
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    name = try container.decodeIfPresent(String.self, forKey: .name)
    type = try container.decode(PlantType.self, forKey: .type)
    radius = try container.decodeIfPresent(Double.self, forKey: .radius)

    // Decode path array if present
    var path: [CLLocationCoordinate2D]? = nil
    if let pathArray = try container.decodeIfPresent([PathCoordinate].self, forKey: .path) {
      path = pathArray.map { pathCoordinate in
        CLLocationCoordinate2D(latitude: pathCoordinate.lat, longitude: pathCoordinate.lng)
      }
    }
    self.path = path
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    try container.encodeIfPresent(name, forKey: .name)
    try container.encode(type, forKey: .type)
    try container.encodeIfPresent(radius, forKey: .radius)

    // Encode path array if present
    if let path = path {
      let pathArray = path.map { coordinate in
        PathCoordinate(lat: coordinate.latitude, lng: coordinate.longitude)
      }
      try container.encode(pathArray, forKey: .path)
    }
  }
}

// MARK: - Helper Types

/// Plant creation request model for API calls
struct PlantCreateRequest: Codable {
  let name: String?
  let type: PlantType
  let latitude: Double
  let longitude: Double
  let radius: Double?

  enum CodingKeys: String, CodingKey {
    case name
    case type
    case latitude
    case longitude
    case radius
  }

  init(from plant: PlantInstance) {
    self.name = plant.name
    self.type = plant.type
    self.latitude = plant.location.latitude
    self.longitude = plant.location.longitude
    self.radius = plant.radius
  }
}
