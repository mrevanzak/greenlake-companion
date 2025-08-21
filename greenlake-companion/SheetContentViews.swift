//
//  SheetContentViews.swift
//  greenlake-companion
//
//  Created by AI Assistant on 21/08/25.
//

import MapKit
import SwiftUI

// MARK: - Default Bottom Sheet Content

struct DefaultBottomSheetContent: View {
  @EnvironmentObject var locationManager: LocationManager

  var body: some View {
    VStack(spacing: 16) {
      // Quick actions
      HStack(spacing: 20) {
        QuickActionButton(
          icon: "location.fill",
          title: "My Location",
          action: {
            locationManager.requestLocation()
          }
        )

        QuickActionButton(
          icon: "car.fill",
          title: "Directions",
          action: {
            // TODO: Open directions from current location
          }
        )

        QuickActionButton(
          icon: "star.fill",
          title: "Favorites",
          action: {
            // TODO: Show favorites
          }
        )

        QuickActionButton(
          icon: "clock.fill",
          title: "Recents",
          action: {
            // TODO: Show recent locations
          }
        )
      }
      .padding(.horizontal, 20)

      Spacer()
    }
    .padding(.top, 8)
  }
}

struct QuickActionButton: View {
  let icon: String
  let title: String
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      VStack(spacing: 8) {
        Image(systemName: icon)
          .font(.system(size: 20, weight: .medium))
          .foregroundColor(.accentColor)
          .frame(width: 44, height: 44)
          .background(.regularMaterial, in: Circle())

        Text(title)
          .font(.caption)
          .foregroundColor(.primary)
          .multilineTextAlignment(.center)
      }
    }
    .frame(maxWidth: .infinity)
  }
}
