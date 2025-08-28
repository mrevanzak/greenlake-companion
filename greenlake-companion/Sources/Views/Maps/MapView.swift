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
  @State private var pins: [MapPin] = []
  @State private var selectedPin: MapPin?
  @State private var showingPinDetails = false

  var body: some View {
    ZStack(alignment: .bottom) {
      MapViewRepresentable(
        locationManager: locationManager,
        pins: $pins,
        selectedPin: $selectedPin
      )
      .ignoresSafeArea()

      // Pin management controls
      VStack {
        Spacer()

        HStack {
          Spacer()

          VStack(spacing: 12) {
            // Clear all pins button
            if !pins.isEmpty {
              Button(action: clearAllPins) {
                Image(systemName: "trash.circle.fill")
                  .font(.title2)
                  .foregroundColor(.red)
                  .background(Color.white)
                  .clipShape(Circle())
                  .shadow(radius: 3)
              }
              .accessibilityLabel("Clear all pins")
            }

            // Add pin info button
            if let selectedPin = selectedPin {
              Button(action: { showingPinDetails = true }) {
                Image(systemName: "info.circle.fill")
                  .font(.title2)
                  .foregroundColor(.blue)
                  .background(Color.white)
                  .clipShape(Circle())
                  .shadow(radius: 3)
              }
              .accessibilityLabel("Pin details")
            }
          }
          .padding(.trailing, 20)
          .padding(.bottom, 100)  // Account for safe area
        }
      }
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
      isPresented: $showingPinDetails, configuration: AdaptiveSheetConfiguration(detents: [.large])
    ) {
      if let selectedPin = selectedPin {
        PinDetailView(
          pin: selectedPin, onDelete: deletePin,
          onDismiss: { showingPinDetails = false }
        )
      }
    }
    .onChange(of: selectedPin) { newValue in
      showingPinDetails = newValue != nil
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
      pins.removeAll()
      selectedPin = nil
    }

    // Provide haptic feedback
    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
    impactFeedback.impactOccurred()
  }

  private func deletePin(_ pin: MapPin) {
    withAnimation(.easeInOut(duration: 0.3)) {
      pins.removeAll { $0.id == pin.id }
      if selectedPin?.id == pin.id {
        selectedPin = nil
      }
    }

    // Provide haptic feedback
    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
    impactFeedback.impactOccurred()
  }
}

// MARK: - Pin Detail View

struct PinDetailView: View {
  let pin: MapPin
  let onDelete: (MapPin) -> Void
  let onDismiss: () -> Void

  var body: some View {
    VStack(spacing: 0) {
      // Header with title and action buttons
      VStack(alignment: .leading, spacing: 16) {
        HStack {
          VStack(alignment: .leading, spacing: 4) {
            Text(pin.title ?? "Unnamed Location")
              .font(.title2)
              .fontWeight(.semibold)
              .foregroundColor(.primary)

            HStack(spacing: 4) {
              Image(systemName: "mappin.circle.fill")
                .foregroundColor(.blue)
                .font(.caption)

              Text("Marked Location")
                .font(.caption)
                .foregroundColor(.secondary)

              Text("•")
                .font(.caption)
                .foregroundColor(.secondary)

              Text("900 m away")
                .font(.caption)
                .foregroundColor(.secondary)
            }
          }

          Spacer()

          // Action buttons in header
          Button(action: { onDismiss() }) {
            Image(systemName: "xmark")
              .font(.title3)
              .foregroundColor(Color.gray)
              .background(.ultraThickMaterial)
          }
        }

      }
    }
  }
}

// MARK: - Preview

#Preview {
  MapView()
}
