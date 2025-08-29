//
//  MapsView.swift
//  greenlake-companion
//
//  Created by AI Assistant on 21/08/25.
//

import MapKit
import SwiftUI
import SwiftUIX

/// Main Maps view replicating Apple Maps interface and functionality
struct MapView: View {
  @StateObject private var locationManager = LocationManager()
  @State private var plants: [PlantInstance] = []
  @State private var selectedPlant: PlantInstance?
  @State private var showingPlantDetails = false

  var body: some View {
    ZStack(alignment: .bottom) {
      MapViewRepresentable(
        locationManager: locationManager,
        plants: $plants,
        selectedPlant: $selectedPlant
      )
      .ignoresSafeArea()
    }
    .environmentObject(locationManager)
    .onAppear {
      setupInitialState()
    }
    .adaptiveSheet(
      isPresented: .constant(true),
      configuration: AdaptiveSheetConfiguration(detents: [.height(100), .large])
    ) {
      BottomSheetContent()
    }
    .adaptiveSheet(
      isPresented: $showingPlantDetails,
      configuration: AdaptiveSheetConfiguration(detents: [.large])
    ) {
      if let selectedPlant = selectedPlant {
        PlantDetailView(
          plant: selectedPlant,
          onDelete: deletePlant,
          onDismiss: { showingPlantDetails = false },
          onSave: handleSave
        )
      }
    }
    .onChange(of: selectedPlant) { newValue in
      showingPlantDetails = newValue != nil
    }
  }

  // MARK: - Helper Methods

  private func setupInitialState() {
    // Request location permission and start tracking
    locationManager.requestLocation()
  }

  private func clearAllPins() {
    print("Clearing all pins")
    withAnimation(.easeInOut(duration: 0.3)) {
      plants.removeAll()
      selectedPlant = nil
    }

    // Provide haptic feedback
    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    impactFeedback.impactOccurred()
  }

  private func deletePlant(_ plant: PlantInstance) {
    withAnimation(.easeInOut(duration: 0.3)) {
      plants.removeAll { $0.id == plant.id }
      if selectedPlant?.id == plant.id {
        selectedPlant = nil
      }
    }

    // Provide haptic feedback
    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
    impactFeedback.impactOccurred()
  }

  private func handleSave(id: UUID, name: String?, type: PlantType) {
    if let idx = plants.firstIndex(where: { $0.id == id }) {
      plants[idx].name = (name?.isEmpty == false) ? name : nil
      plants[idx].type = type
    }
    showingPlantDetails = false
  }
}

// MARK: - Preview

#Preview {
  MapView()
}
