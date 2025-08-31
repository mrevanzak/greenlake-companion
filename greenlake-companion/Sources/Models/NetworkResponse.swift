//
//  NetworkResponse.swift
//  greenlake-companion
//
//  Created by AI Assistant on 28/08/25.
//

import Foundation

/// Generic API response wrapper
struct APIResponse<T: Codable>: Codable {
  let success: Bool
  let message: String
  let data: T
}

/// Specific response for plants endpoint
typealias PlantsResponse = APIResponse<[PlantInstance]>

/// Specific response for single plant endpoint
typealias PlantResponse = APIResponse<PlantInstance>

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

  enum CodingKeys: String, CodingKey {
    case name
    case type
    case radius
  }
}

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
