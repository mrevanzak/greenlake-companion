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

  var body: some View {
    ZStack(alignment: .bottom) {
      // MARK: - Main Map View
      MapViewRepresentable(
        locationManager: locationManager
      )
      .ignoresSafeArea()

    }
    .environmentObject(locationManager)
    .onAppear {
      setupInitialState()
    }
    // Native sheets
    .sheet(isPresented: .constant(true)) {
      DefaultBottomSheetContent()
        .presentationDetents([.height(100), .medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackgroundInteraction(.enabled)
        .interactiveDismissDisabled()
    }
  }

  // MARK: - Helper Methods

  private func setupInitialState() {
    // Request location permission and start tracking
    locationManager.requestLocation()
  }

}

// MARK: - Extensions

extension CLLocationCoordinate2D {
  var location: CLLocation {
    return CLLocation(latitude: latitude, longitude: longitude)
  }
}

// MARK: - Preview

#Preview {
  MapsView()
}
