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
  @StateObject private var plantManager = PlantManager()
  @State private var showingPlantDetails = false

  var body: some View {
    ZStack(alignment: .bottom) {
      MapViewRepresentable(
        locationManager: locationManager,
        plantManager: plantManager
      )
      .ignoresSafeArea()

      // Loading indicator
      if plantManager.isLoading {
        VStack {
          ProgressView("Loading...")
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.top, 100)
      }
    }
    .environmentObject(locationManager)
    .onAppear {
      setupInitialState()
      Task {
        await plantManager.loadPlants()
      }
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
      if let selectedPlant = plantManager.selectedPlant {
        PlantDetailView(
          plant: selectedPlant,
          isCreationMode: false,
          onDelete: { plant in
            Task { await plantManager.deletePlant(plant) }
          },
          onDismiss: {
            showingPlantDetails = false
            plantManager.selectPlant(nil)
          },
          onSave: { name, type, radius in
            Task {
              await plantManager.updatePlant(selectedPlant, name: name, type: type, radius: radius)
            }
          }
        )
      }
    }
    .adaptiveSheet(
      isPresented: $plantManager.isCreatingPlant,
      configuration: AdaptiveSheetConfiguration(detents: [.large])
    ) {
      if let tempPlant = plantManager.temporaryPlant {
        PlantDetailView(
          plant: tempPlant,
          isCreationMode: true,
          onDelete: { _ in plantManager.discardTemporaryPlant() },
          onDismiss: { plantManager.discardTemporaryPlant() },
          onSave: { name, type, radius in
            // Update temporary plant with user input and confirm
            plantManager.updateTemporaryPlant(name: name, type: type, radius: radius)
            Task { await plantManager.confirmTemporaryPlant() }
          }
        )
      }
    }
    .onChange(of: plantManager.selectedPlant) { newValue in
      showingPlantDetails = newValue != nil
    }
    .alert("Error", isPresented: .constant(plantManager.error != nil)) {
      Button("OK") { plantManager.clearError() }
    } message: {
      if let error = plantManager.error {
        Text(error.localizedDescription)
      }
    }
  }

  // MARK: - Helper Methods

  private func setupInitialState() {
    // Request location permission and start tracking
    locationManager.requestLocation()
  }
}

// MARK: - Preview

#Preview {
  MapView()
}
