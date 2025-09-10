//
//  MapsView.swift
//  greenlake-companion
//
//  Created by AI Assistant on 21/08/25.
//

import MapKit
import SwiftUI

/// Main Maps view replicating Apple Maps interface and functionality
struct MapView: View {
  @StateObject private var locationManager = LocationManager()
  @StateObject private var plantManager = PlantManager.shared
  @StateObject private var filterVM = MapFilterViewModel()

  @EnvironmentObject private var authManager: AuthManager

  @State private var selectedItem: String = "Mode"
  @State private var showMenu = false

  private let items = ["Pencatatan", "Label", "Label 2"]

  var showingPlantDetail: Binding<Bool> {
    Binding(
      get: { plantManager.hasSelectedPlant },
      set: { _ in }
    )
  }

  var body: some View {
    ZStack(alignment: .bottom) {
      // Map background
      mapContent

      VStack(alignment: .trailing) {
        HStack(alignment: .top) {
          AccountButton()

          Spacer()

          TopControlView()
        }

        Spacer()
      }
      .padding()
      .padding(.vertical, 16)
      .padding(.horizontal, 6)
      .zIndex(1)

      HStack(alignment: .top) {
        Spacer()

        VStack(alignment: .trailing) {
          PlantTypeLayerFilter()
          MapTypeControl()
          Spacer()

        }
      }
      .padding()
      .padding(.top, 70)
      .padding(.horizontal, 6)
      .zIndex(0)

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
      configuration: AdaptiveSheetConfiguration(detents: [.height(80), .large])
    ) {
      MainSheetView()
    }
    .adaptiveSheet(
      isPresented: $plantManager.isCreatingPlant,
      configuration: AdaptiveSheetConfiguration(detents: [.large])
    ) {
      PlantFormView(mode: .create)
    }
    .adaptiveSheet(
      isPresented: showingPlantDetail,
      configuration: AdaptiveSheetConfiguration(
        detents: [.large],
        onDismiss: {
          plantManager.selectPlant(nil)
        })
    ) {
      PlantDetailView()
    }
  }

  // MARK: - View Components

  private var mapContent: some View {
    MapViewRepresentable()
      .accessibilityHidden(true)
      .ignoresSafeArea()
  }

  private var logoutButton: some View {
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
  }

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
