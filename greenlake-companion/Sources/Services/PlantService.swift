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
  func updatePlant(_ plant: PlantInstance) async throws -> PlantInstance
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
    do {
      print("🌱 Creating plant in API...")
      let response: PlantResponse = try await networkManager.request(
        PlantEndpoint.createPlant, with: plant)
      print("✅ Successfully created plant in API")
      return response.data
    } catch {
      print("❌ Error creating plant in API: \(error)")
      throw error
    }
  }

  func updatePlant(_ plant: PlantInstance) async throws -> PlantInstance {
    do {
      print("🌱 Updating plant in API...")
      let response: PlantResponse = try await networkManager.request(
        PlantEndpoint.updatePlant(id: plant.id), with: plant)
      print("✅ Successfully updated plant in API")
      return response.data
    } catch {
      print("❌ Error updating plant in API: \(error)")
      throw error
    }
  }

  func deletePlant(_ id: UUID) async throws {
    do {
      print("🌱 Deleting plant in API...")
      let _: MessageOnlyResponse = try await networkManager.request(
        PlantEndpoint.deletePlant(id: id))
      print("✅ Successfully deleted plant in API")
    } catch {
      print("❌ Error deleting plant in API: \(error)")
      throw error
    }
  }
}
