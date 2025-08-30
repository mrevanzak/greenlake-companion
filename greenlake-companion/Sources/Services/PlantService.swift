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
  func updatePlant(_ id: UUID, name: String?, type: PlantType) async throws -> PlantInstance
  func deletePlant(_ id: UUID) async throws
}

/// Plant service implementation starting with mock data, ready for API integration
class PlantService: PlantServiceProtocol {
  // MARK: - Properties

  private let baseURL = "https://api.greenlake.com/v1"
  private let session: URLSession

  // MARK: - Initialization

  init(session: URLSession = .shared) {
    self.session = session
  }

  // MARK: - PlantServiceProtocol Implementation

  func fetchPlants() async throws -> [PlantInstance] {
    // TODO: Replace with actual API call
    // For now, return mock data
    return mockPlants
  }

  func createPlant(_ plant: PlantInstance) async throws -> PlantInstance {
    // TODO: Replace with actual API call
    // For now, simulate network delay and return the plant
    try await Task.sleep(nanoseconds: 500_000_000)  // 0.5 seconds

    // Simulate potential errors
    if plant.coordinate.latitude == 0 && plant.coordinate.longitude == 0 {
      throw PlantError.invalidCoordinate
    }

    return plant
  }

  func updatePlant(_ id: UUID, name: String?, type: PlantType) async throws -> PlantInstance {
    // TODO: Replace with actual API call
    // For now, simulate network delay and return updated plant
    try await Task.sleep(nanoseconds: 300_000_000)  // 0.3 seconds

    // Simulate finding and updating the plant
    guard let existingPlant = mockPlants.first(where: { $0.id == id }) else {
      throw PlantError.plantNotFound
    }

    var updatedPlant = existingPlant
    updatedPlant.name = name
    updatedPlant.type = type

    return updatedPlant
  }

  func deletePlant(_ id: UUID) async throws {
    // TODO: Replace with actual API call
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
        coordinate: CLLocationCoordinate2D(latitude: -7.308118, longitude: 112.6550),
        name: "Douglas Fir",
        type: .tree,
        createdAt: Date().addingTimeInterval(-86400)  // 1 day ago
      ),
      PlantInstance(
        coordinate: CLLocationCoordinate2D(latitude: -7.308118, longitude: 112.660),
        name: "Western Red Cedar",
        type: .tree,
        createdAt: Date().addingTimeInterval(-172800)  // 2 days ago
      ),
      PlantInstance(
        coordinate: CLLocationCoordinate2D(latitude: -7.308765, longitude: 112.656825),
        name: "Salal",
        type: .groundCover,
        createdAt: Date().addingTimeInterval(-259200)  // 3 days ago
      ),
    ]
  }
}
