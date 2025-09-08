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

  var body: some View {
    ZStack(alignment: .bottom) {
      // Map background
      mapContent

      // Loading indicator overlay
      loadingIndicator

      VStack {
        HStack(alignment: .top) {
          AccountButton()

          Spacer()

          TopControlView()

        }
       
          
          HStack {
              Spacer()
              
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
                        Text("Layers")
                      }
              //        .padding(.horizontal, 12)
              //        .padding(.vertical, 10)
                      .background(.ultraThinMaterial)
                      .clipShape(Capsule())
                    }
                    .accessibilityLabel("Layer filters")
          }
          
        Spacer()
      }
      .padding(.top, 24)
      .padding(.horizontal, 22)
      Spacer()
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
      configuration: AdaptiveSheetConfiguration(detents: [.height(108), .large])
    ) {
      MainSheetView()
    }
  }

  // MARK: - View Components

  private var mapContent: some View {
    MapViewRepresentable(
      locationManager: locationManager,
      plantManager: plantManager
    )
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

  private var loadingIndicator: some View {
    Group {
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
