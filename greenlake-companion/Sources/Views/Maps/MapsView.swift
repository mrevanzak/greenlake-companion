//
//  MapsView.swift
//  greenlake-companion
//
//  Created by AI Assistant on 21/08/25.
//

import MapKit
import SwiftUI

/// Main Maps view replicating Apple Maps interface and functionality with custom tile support
struct MapsView: View {
  @StateObject private var locationManager = LocationManager()
  @Binding var useCustomTiles: Bool

  var body: some View {
    ZStack(alignment: .bottom) {
      MapViewRepresentable(
        locationManager: locationManager,
        useCustomTiles: useCustomTiles,
      )
      .ignoresSafeArea()
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
  MapsView(useCustomTiles: .constant(true))
}
