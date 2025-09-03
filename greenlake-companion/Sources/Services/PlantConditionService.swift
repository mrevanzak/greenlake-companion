//
//  PlantConditionService.swift
//  greenlake-companion
//
//  Created by AI Assistant on 05/01/25.
//

import Combine
import Foundation

@MainActor
class PlantConditionService: ObservableObject {
  static let shared = PlantConditionService()

  @Published var plantConditions: [PlantCondition] = []
  @Published var isLoading = false
  @Published var error: PlantError?

  private init() {
    loadPlantConditions()
  }

  // MARK: - Public Methods

  /// Save a new plant condition record
  func savePlantCondition(_ condition: PlantCondition) async throws {
    isLoading = true
    error = nil

    do {
      // TODO: Implement actual API call to save to backend
      // For now, we'll simulate the save operation
      try await Task.sleep(nanoseconds: 1_000_000_000)  // 1 second delay

      // Add to local array
      plantConditions.append(condition)

      // Save to UserDefaults for persistence
      saveToUserDefaults()

    } catch {
      self.error = PlantError.networkError
      throw error
    }

    isLoading = false
  }

  /// Get plant conditions for a specific plant
  func getPlantConditions(for plantId: UUID) -> [PlantCondition] {
    plantConditions.filter { $0.plantId == plantId }
  }

  /// Get all plant conditions
  func getAllPlantConditions() -> [PlantCondition] {
    plantConditions
  }

  /// Delete a plant condition record
  func deletePlantCondition(_ condition: PlantCondition) async throws {
    isLoading = true
    error = nil

    do {
      // TODO: Implement actual API call to delete from backend
      try await Task.sleep(nanoseconds: 500_000_000)  // 0.5 second delay

      // Remove from local array
      plantConditions.removeAll { $0.id == condition.id }

      // Save to UserDefaults
      saveToUserDefaults()

    } catch {
      self.error = PlantError.networkError
      throw error
    }

    isLoading = false
  }

  // MARK: - Private Methods

  /// Load plant conditions from UserDefaults
  private func loadPlantConditions() {
    guard let data = UserDefaults.standard.data(forKey: "plantConditions"),
      let conditions = try? JSONDecoder().decode([PlantCondition].self, from: data)
    else {
      return
    }
    plantConditions = conditions
  }

  /// Save plant conditions to UserDefaults
  private func saveToUserDefaults() {
    guard let data = try? JSONEncoder().encode(plantConditions) else { return }
    UserDefaults.standard.set(data, forKey: "plantConditions")
  }
}

// MARK: - Extensions

extension PlantConditionService {
  /// Get plant conditions grouped by plant ID
  var plantConditionsByPlant: [UUID: [PlantCondition]] {
    Dictionary(grouping: plantConditions) { $0.plantId }
  }

  /// Get the most recent condition for each plant
  var latestConditionsByPlant: [UUID: PlantCondition] {
    var latestConditions: [UUID: PlantCondition] = [:]

    for condition in plantConditions {
      if let existing = latestConditions[condition.plantId] {
        if condition.recordedAt > existing.recordedAt {
          latestConditions[condition.plantId] = condition
        }
      } else {
        latestConditions[condition.plantId] = condition
      }
    }

    return latestConditions
  }

  /// Get plant conditions count for a specific plant
  func getConditionCount(for plantId: UUID) -> Int {
    plantConditions.filter { $0.plantId == plantId }.count
  }
}
