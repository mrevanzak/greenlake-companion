//
//  MapsView.swift
//  greenlake-companion
//
//  Created by AI Assistant on 21/08/25.
//

import MapKit
import SwiftUI

/// Main Maps view replicating Apple Maps interface and functionality
struct MapsView: View {
  @StateObject private var locationManager = LocationManager()
  @State private var showSheet = true

  var body: some View {
    ZStack(alignment: .bottom) {
      MapViewRepresentable(locationManager: locationManager)
        .ignoresSafeArea()
    }
    .adaptiveSheet(isPresented: $showSheet) {
      DefaultBottomSheetContent()
        .presentationDetents([.height(100), .medium])
        .presentationDragIndicator(.visible)
        .presentationBackgroundInteraction(.enabled)
        .interactiveDismissDisabled()
    }
    .environmentObject(locationManager)
    .onAppear {
      setupInitialState()
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
  MapsView()
}
