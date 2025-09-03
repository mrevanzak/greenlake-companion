//
//  MapFilterViewModel.swift
//  greenlake-companion
//
//  Created by AI Assistant on 03/09/25.
//

import Foundation

/// Controls plant-type filtering for Maps; empty selection shows all.
final class MapFilterViewModel: ObservableObject {
  @Published var selectedPlantTypes: Set<PlantType> = [] {
    didSet { save() }
  }

  private let storageKey = "map.selectedPlantTypes"

  init() {
    load()
  }

  /// Toggle inclusion of a specific plant type in the filter set.
  func toggle(_ plantType: PlantType) {
    if selectedPlantTypes.contains(plantType) {
      selectedPlantTypes.remove(plantType)
    } else {
      selectedPlantTypes.insert(plantType)
    }
  }

  /// Select none to show all plant types.
  func showAll() {
    selectedPlantTypes = []
  }

  private func load() {
    guard let rawValues = UserDefaults.standard.array(forKey: storageKey) as? [String],
      !rawValues.isEmpty
    else {
      selectedPlantTypes = []
      return
    }

    let types = rawValues.compactMap { PlantType(rawValue: $0) }
    selectedPlantTypes = Set(types)
  }

  private func save() {
    let rawValues = selectedPlantTypes.map { $0.rawValue }
    UserDefaults.standard.set(rawValues, forKey: storageKey)
  }
}
