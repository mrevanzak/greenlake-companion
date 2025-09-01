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
  @StateObject private var plantManager = PlantManager.shared
  @EnvironmentObject private var authManager: AuthManager
  @State private var showingPlantDetails = false

  var body: some View {
    ZStack(alignment: .bottom) {
      MapViewRepresentable(
        locationManager: locationManager,
        plantManager: plantManager
      )
      .ignoresSafeArea()

      // Top-right logout button
      VStack {
        HStack {
          Spacer()
          Button(action: {
            authManager.logout()
          }) {
            Image(systemName: "rectangle.portrait.and.arrow.right")
              .font(.title2)
              .foregroundColor(.primary)
              .padding(12)
              .background(.ultraThinMaterial)
              .clipShape(Circle())
          }
          .padding(.trailing, 20)
          .padding(.top, 60)
        }
        Spacer()
      }

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
          mode: .update,
          onDismiss: {
            showingPlantDetails = false
            plantManager.selectPlant(nil)
          },
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
          mode: .create,
          onDismiss: { plantManager.discardTemporaryPlant() },
        )
      }
    }
    .onChange(of: plantManager.selectedPlant) { oldValue, newValue in
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
    .environmentObject(AuthManager.shared)
}
