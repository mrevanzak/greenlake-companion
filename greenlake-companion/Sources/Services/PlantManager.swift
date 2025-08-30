//
//  PlantManager.swift
//  greenlake-companion
//
//  Created by AI Assistant on 28/08/25.
//

import CoreLocation
import Foundation
import SwiftUI

/// Centralized plant state management service following MVVM architecture
@MainActor
class PlantManager: ObservableObject {
  // MARK: - Published Properties

  @Published var plants: [PlantInstance] = []
  @Published var selectedPlant: PlantInstance?
  @Published var isLoading = false
  @Published var error: PlantError?

  // MARK: - Temporary Plant State

  @Published var temporaryPlant: PlantInstance?
  @Published var isCreatingPlant = false

  // MARK: - Private Properties

  private let plantService: PlantServiceProtocol

  // MARK: - Initialization

  init(plantService: PlantServiceProtocol = PlantService()) {
    self.plantService = plantService
  }

  // MARK: - Public Methods

  /// Load all plants from the service
  func loadPlants() async {
    isLoading = true
    error = nil

    do {
      let fetchedPlants = try await plantService.fetchPlants()
      plants = fetchedPlants
    } catch let serviceError {
      self.error = PlantError.loadFailed(serviceError)
    }

    isLoading = false
  }

  /// Create a temporary plant at the specified coordinate
  /// - Parameter coordinate: The location where the plant should be added
  func createTemporaryPlant(at coordinate: CLLocationCoordinate2D) {
    let tempPlant = PlantInstance(
      coordinate: coordinate,
      name: nil,
      type: .tree
    )
    temporaryPlant = tempPlant
    isCreatingPlant = true
  }

  /// Update the temporary plant with user input
  /// - Parameters:
  ///   - name: Optional name for the plant
  ///   - type: Plant type
  func updateTemporaryPlant(name: String?, type: PlantType) {
    guard var tempPlant = temporaryPlant else { return }
    tempPlant.name = name
    tempPlant.type = type
    temporaryPlant = tempPlant
  }

  /// Confirm the temporary plant and save it to the service
  func confirmTemporaryPlant() async {
    guard let tempPlant = temporaryPlant else { return }

    isLoading = true
    error = nil

    do {
      let createdPlant = try await plantService.createPlant(tempPlant)
      plants.append(createdPlant)
      clearTemporaryPlant()
    } catch let serviceError {
      self.error = PlantError.createFailed(serviceError)
    }

    isLoading = false
  }

  /// Discard the temporary plant without saving
  func discardTemporaryPlant() {
    clearTemporaryPlant()
  }

  /// Clear temporary plant state
  private func clearTemporaryPlant() {
    temporaryPlant = nil
    isCreatingPlant = false
  }

  /// Add a new plant at the specified coordinate
  /// - Parameter coordinate: The location where the plant should be added
  func addPlant(at coordinate: CLLocationCoordinate2D) async {
    isLoading = true
    error = nil

    let newPlant = PlantInstance(
      coordinate: coordinate,
      name: nil,
      type: .tree
    )

    do {
      let createdPlant = try await plantService.createPlant(newPlant)
      plants.append(createdPlant)
      selectedPlant = createdPlant
    } catch let serviceError {
      self.error = PlantError.createFailed(serviceError)
    }

    isLoading = false
  }

  /// Update an existing plant's properties
  /// - Parameters:
  ///   - plant: The plant to update
  ///   - name: Optional new name for the plant
  ///   - type: New plant type
  func updatePlant(_ plant: PlantInstance, name: String?, type: PlantType) async {
    isLoading = true
    error = nil

    do {
      let updatedPlant = try await plantService.updatePlant(plant.id, name: name, type: type)

      // Update the plant in our local array
      if let index = plants.firstIndex(where: { $0.id == plant.id }) {
        plants[index] = updatedPlant

        // Update selected plant if it's the one being edited
        if selectedPlant?.id == plant.id {
          selectedPlant = updatedPlant
        }
      }
    } catch let serviceError {
      self.error = PlantError.updateFailed(serviceError)
    }

    isLoading = false
  }

  /// Delete a plant from the system
  /// - Parameter plant: The plant to delete
  func deletePlant(_ plant: PlantInstance) async {
    isLoading = true
    error = nil

    do {
      try await plantService.deletePlant(plant.id)

      // Remove from local array
      plants.removeAll { $0.id == plant.id }

      // Clear selection if this was the selected plant
      if selectedPlant?.id == plant.id {
        selectedPlant = nil
      }
    } catch let serviceError {
      self.error = PlantError.deleteFailed(serviceError)
    }

    isLoading = false
  }

  /// Select a plant for detailed viewing/editing
  /// - Parameter plant: The plant to select
  func selectPlant(_ plant: PlantInstance?) {
    selectedPlant = plant
  }

  /// Clear any current error
  func clearError() {
    error = nil
  }

  /// Clear all plants (useful for testing or reset)
  func clearAllPlants() {
    plants.removeAll()
    selectedPlant = nil
    error = nil
  }

  // MARK: - Computed Properties

  /// Number of plants in the system
  var plantCount: Int {
    plants.count
  }

  /// Plants grouped by type
  var plantsByType: [PlantType: [PlantInstance]] {
    Dictionary(grouping: plants) { $0.type }
  }

  /// Check if there are any plants
  var hasPlants: Bool {
    !plants.isEmpty
  }

  /// Check if a plant is currently selected
  var hasSelectedPlant: Bool {
    selectedPlant != nil
  }
}
