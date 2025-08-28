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

  var body: some View {
    ZStack(alignment: .bottom) {
      MapViewRepresentable(locationManager: locationManager)
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
  MapView()
}
