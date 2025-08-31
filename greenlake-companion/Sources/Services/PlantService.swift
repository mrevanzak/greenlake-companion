//
//  PlantService.swift
//  greenlake-companion
//
//  Created by AI Assistant on 28/08/25.
//

import CoreLocation
import Foundation

/// Protocol defining plant service operations for easy testing and API integration
protocol PlantServiceProtocol {
  func fetchPlants() async throws -> [PlantInstance]
  func createPlant(_ plant: PlantInstance) async throws -> PlantInstance
  func updatePlant(_ id: UUID, name: String, type: PlantType, radius: Double?) async throws
    -> PlantInstance
  func deletePlant(_ id: UUID) async throws
}

/// Plant service implementation starting with mock data, ready for API integration
class PlantService: PlantServiceProtocol {
  // MARK: - Properties

  private let networkManager: NetworkManagerProtocol

  // MARK: - Initialization

  init(networkManager: NetworkManagerProtocol = NetworkManager()) {
    self.networkManager = networkManager
  }

  // MARK: - PlantServiceProtocol Implementation

  func fetchPlants() async throws -> [PlantInstance] {
    do {
      print("🌱 Fetching plants from API...")
      let response: PlantsResponse = try await networkManager.request(PlantEndpoint.fetchPlants)
      print("✅ Successfully decoded \(response.data.count) plants from API")

      return response.data
    } catch {
      print("❌ Error decoding plants response: \(error)")
      if let decodingError = error as? DecodingError {
        print("🔍 Decoding error details: \(decodingError)")
        switch decodingError {
        case .keyNotFound(let key, let context):
          print("   Missing key: \(key.stringValue) at path: \(context.codingPath)")
        case .typeMismatch(let type, let context):
          print("   Type mismatch: expected \(type) at path: \(context.codingPath)")
        case .valueNotFound(let type, let context):
          print("   Value not found: expected \(type) at path: \(context.codingPath)")
        case .dataCorrupted(let context):
          print("   Data corrupted at path: \(context.codingPath): \(context.debugDescription)")
        @unknown default:
          print("   Unknown decoding error")
        }
      }
      throw error
    }
  }

  func createPlant(_ plant: PlantInstance) async throws -> PlantInstance {
    // TODO: Replace with actual API call
    // let response: PlantResponse = try await networkManager.request(PlantEndpoint.createPlant, with: plant)
    // return response.data

    // For now, simulate network delay and return the plant
    try await Task.sleep(nanoseconds: 500_000_000)  // 0.5 seconds

    // Simulate potential errors
    if plant.location.latitude == 0 && plant.location.longitude == 0 {
      throw PlantError.invalidCoordinate
    }

    return plant
  }

  func updatePlant(_ id: UUID, name: String, type: PlantType, radius: Double?) async throws
    -> PlantInstance
  {
    // TODO: Replace with actual API call
    // let updateData = PlantUpdateRequest(name: name, type: type, radius: radius)
    // let response: PlantResponse = try await networkManager.request(PlantEndpoint.updatePlant(id: id), with: updateData)
    // return response.data
    // For now, simulate network delay and return updated plant
    try await Task.sleep(nanoseconds: 300_000_000)  // 0.3 seconds

    // Simulate finding and updating the plant
    guard let existingPlant = mockPlants.first(where: { $0.id == id }) else {
      throw PlantError.plantNotFound
    }

    var updatedPlant = existingPlant
    updatedPlant.name = name
    updatedPlant.type = type
    updatedPlant.radius = radius

    return updatedPlant
  }

  func deletePlant(_ id: UUID) async throws {
    // TODO: Replace with actual API call
    // try await networkManager.request(PlantEndpoint.deletePlant(id: id))
    // For now, simulate network delay
    try await Task.sleep(nanoseconds: 200_000_000)  // 0.2 seconds

    // Simulate potential errors
    guard mockPlants.contains(where: { $0.id == id }) else {
      throw PlantError.plantNotFound
    }
  }

  // MARK: - Private Methods

  private var mockPlants: [PlantInstance] {
    [
      PlantInstance(
        type: .tree,
        name: "Douglas Fir",
        location: CLLocationCoordinate2D(latitude: -7.308118, longitude: 112.6550),
        radius: 8.0,
        createdAt: Date().addingTimeInterval(-86400),  // 1 day ago
        updatedAt: Date().addingTimeInterval(-86400),  // 1 day ago
      ),
      PlantInstance(
        type: .tree,
        name: "Western Red Cedar",
        location: CLLocationCoordinate2D(latitude: -7.308118, longitude: 112.660),
        radius: 12.0,
        createdAt: Date().addingTimeInterval(-172800),  // 2 days ago
        updatedAt: Date().addingTimeInterval(-172800),  // 2 days ago
      ),
      PlantInstance(
        type: .groundCover,
        name: "Salal",
        location: CLLocationCoordinate2D(latitude: -7.308765, longitude: 112.656825),
        path: [
          CLLocationCoordinate2D(latitude: -7.308765, longitude: 112.656825),
          CLLocationCoordinate2D(latitude: -7.308765, longitude: 112.656825),
        ],
        createdAt: Date().addingTimeInterval(-259200),  // 3 days ago
        updatedAt: Date().addingTimeInterval(-259200),  // 3 days ago

      ),
    ]
  }
}
