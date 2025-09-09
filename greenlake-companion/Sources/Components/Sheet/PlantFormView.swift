//
//  PlantDetailView.swift
//  greenlake-companion
//
//  Created by AI Assistant on 28/08/25.
//

import CoreLocation
import SwiftUI

enum Mode {
  case create
  case update
}

struct PlantFormView: View {
  let mode: Mode

  @StateObject private var plantManager = PlantManager.shared

  @State private var nameInput: String = ""
  @State private var typeInput: PlantType = .tree
  @State private var radiusInput: Double = 5.0
  @State private var pathPoints: [CLLocationCoordinate2D] = []
  @State private var showingDeleteConfirmation = false

  @Environment(\.dismiss) var dismiss

  var plant: PlantInstance {
    switch mode {
    case .create:
      return plantManager.temporaryPlant ?? PlantInstance.empty()
    case .update:
      return plantManager.selectedPlant ?? PlantInstance.empty()
    }
  }

  private func initialState(plant: PlantInstance) {
    nameInput = plant.name
    typeInput = plant.type
    radiusInput = plant.radius ?? 5.0
    pathPoints = plant.path ?? []

    // Sync with PlantManager's current path points for non-tree types
    if plant.type != .tree {
      plantManager.currentPathPoints = plant.path ?? []
    }
  }

  private func onDelete() {
    if mode == .create {
      plantManager.discardTemporaryPlant()
      return
    }

    Task {
      await plantManager.deletePlant(plant)
    }
  }

  private func onSave() {
    let radius = typeInput == .tree ? radiusInput : nil
    let path = typeInput != .tree ? (pathPoints.count >= 3 ? pathPoints : nil) : nil

    if mode == .update {
      Task {
        await plantManager.updatePlant(
          plant.with(name: nameInput, type: typeInput, radius: radius, path: path))
      }
      return
    }

    // Update temporary plant with user input and confirm
    plantManager.updateTemporaryPlant(
      name: nameInput, type: typeInput, radius: radius, path: path)
    Task {
      await plantManager.confirmTemporaryPlant()
    }
  }

  var body: some View {
    Form {
      detailsSection

      if typeInput != .tree {
        areaDrawingSection
      }

      if mode == .update {
        deleteSection
      }
    }
    .scrollContentBackground(.hidden)
    .background(.clear)
    .navigationTitle(Text(mode == .create ? "New Plant" : plant.name))
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button("Save") {
          onSave()
        }
      }
    }
    .onAppear {
      initialState(plant: plant)
    }
    .onChange(of: plant) { oldPlant, newPlant in
      initialState(plant: newPlant)
    }
    .onChange(of: typeInput) { oldType, newType in
      if newType != .tree {
        radiusInput = 5.0  // Reset radius for non-tree types

        if plantManager.currentPathPoints.isEmpty {
          plantManager.startPathDrawing(withInitialPoint: plant.location)
        }
      } else {
        // Clear path when switching to tree type
        plantManager.clearPath()
        plantManager.stopPathDrawing()
        pathPoints.removeAll()
      }
    }
    .onChange(of: plantManager.isDrawingPath) { oldValue, newValue in
      // Stop drawing when switching away from non-tree types
      if newValue && typeInput == .tree {
        plantManager.stopPathDrawing()
      }
    }
    .onReceive(plantManager.$currentPathPoints) { newPoints in
      if typeInput != .tree {
        pathPoints = newPoints
      }
    }
  }

  // MARK: - View Components

  private var detailsSection: some View {
    Section(
      header: Text("Details"),
      footer: Text(
        "Coordinates: \(plant.location.latitude ?? 0), \(plant.location.longitude ?? 0)")
    ) {
      TextField("Name", text: $nameInput)
        .textInputAutocapitalization(.words)
        .disableAutocorrection(true)

      Picker("Type", selection: $typeInput) {
        ForEach(PlantType.allCases) { type in
          Text(type.displayName).tag(type)
        }
      }

      if typeInput == .tree {
        HStack {
          Text("Radius")
          Spacer()
          Stepper(
            value: $radiusInput,
            in: 0.5...50.0,
            step: 0.5
          ) {
            Text("\(radiusInput, specifier: "%.1f") m")
              .foregroundColor(.secondary)
          }
        }
      }

      if typeInput != .tree {
        HStack {
          Text("Path Points")
          Spacer()
          Text("\(pathPoints.count)")
            .foregroundColor(.secondary)
        }

      }
    }
    .listRowBackground(Color(.systemGray6))
  }

  private var areaDrawingSection: some View {
    Section(header: Text("Area Drawing")) {
      HStack {
        Button(action: {
          if plantManager.isDrawingPath {
            plantManager.stopPathDrawing()
          } else {
            plantManager.startPathDrawing()
          }
        }) {
          HStack {
            Image(systemName: plantManager.isDrawingPath ? "pause.circle" : "pencil.circle")
            Text(plantManager.isDrawingPath ? "Stop Drawing" : "Start Drawing")
          }
        }
        .disabled(pathPoints.count >= 20)

        Spacer()

        Button(action: {
          plantManager.clearPath()
        }) {
          HStack {
            Image(systemName: "trash.circle")
            Text("Clear Path")
          }
          .foregroundColor(.red)
        }
        .disabled(pathPoints.isEmpty)
      }

      if plantManager.isDrawingPath {
        Text("🎯 Path drawing mode active - tap on map to add points")
          .font(.caption)
          .foregroundColor(.orange)
          .fontWeight(.medium)
      }
    }
    .listRowBackground(Color(.systemGray6))
  }

  private var deleteSection: some View {
    Section {
      Button(action: { showingDeleteConfirmation = true }) {
        HStack {
          Image(systemName: "trash")
            .foregroundColor(.red)
          Text("Delete Plant")
            .foregroundColor(.red)
        }
      }
    }
    .confirmationDialog(
      "Delete Plant",
      isPresented: $showingDeleteConfirmation,
      titleVisibility: .visible
    ) {
      Button("Delete", role: .destructive) {
        onDelete()
        dismiss()
      }
      Button("Cancel", role: .cancel) {}
    } message: {
      Text("Are you sure you want to delete '\(plant.name)'? This action cannot be undone.")
    }
    .listRowBackground(Color(.systemGray6))
  }
}
