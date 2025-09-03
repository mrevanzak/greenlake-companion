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
  @StateObject private var filterVM = MapFilterViewModel()
  @EnvironmentObject private var authManager: AuthManager
  @State private var showingPlantDetails = false

  var body: some View {
    ZStack(alignment: .topTrailing) {
      MapViewRepresentable(
        locationManager: locationManager,
        plantManager: plantManager
      )
      .accessibilityHidden(true)
      .ignoresSafeArea()
        

      // Floating controls (Layers + Logout)
      VStack(alignment: .trailing, spacing: 12) {
        // Layers menu
        Menu {
          ForEach(PlantType.allCases) { type in
            Button(action: { filterVM.toggle(type) }) {
              Label(
                type.displayName,
                systemImage: filterVM.selectedPlantTypes.contains(type)
                  ? "checkmark.circle.fill" : "circle"
              )
            }
          }
          Divider()
          Button("Show All", action: { filterVM.showAll() })
        } label: {
          HStack(spacing: 8) {
            Image(systemName: "square.3.layers.3d.down.right")
                  .accessibilityLabel("Layer")
            Text("Layers")
          }
          .padding(.horizontal, 12)
          .padding(.vertical, 10)
          .background(.ultraThinMaterial)
          .clipShape(Capsule())
        }
        .accessibilityLabel("Layer filters")

        // Logout button
        Button(action: { authManager.logout() }) {
          Image(systemName: "rectangle.portrait.and.arrow.right")
            .font(.title2)
            .foregroundColor(.primary)
            .padding(12)
            .background(.ultraThinMaterial)
            .clipShape(Circle())
            .accessibilityLabel("Tombol Keluar")
        }
      }
      .padding(.trailing, 16)
      .padding(.top, 16)

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
    .environmentObject(filterVM)
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
