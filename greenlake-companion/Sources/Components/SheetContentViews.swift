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
      // Horizontal stack for iPhone bottom sheet
      HStack(spacing: 20) {
        ForEach(quickActions.indices, id: \.self) { index in
          QuickActionButton(
            icon: quickActions[index].icon,
            title: quickActions[index].title,
            action: quickActions[index].action
          )
        }
      }
      .padding()

      Spacer()
    }
  }

  private var quickActions: [QuickAction] {
    [
      QuickAction(icon: "location.fill", title: "My Location") {
        locationManager.requestLocation()
      },
      QuickAction(icon: "car.fill", title: "Directions") {
        // TODO: Open directions from current location
      },
      QuickAction(icon: "star.fill", title: "Favorites") {
        // TODO: Show favorites
      },
      QuickAction(icon: "clock.fill", title: "Recents") {
        // TODO: Show recent locations
      },
    ]
  }
}

// MARK: - iPad-Optimized Action Row

struct QuickActionRow: View {
  let action: QuickAction

  var body: some View {
    Button(action: action.action) {
      HStack(spacing: 12) {
        Image(systemName: action.icon)
          .font(.system(size: 18, weight: .medium))
          .foregroundColor(.accentColor)
          .frame(width: 32, height: 32)
          .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))

        Text(action.title)
          .font(.body)
          .foregroundColor(.primary)

        Spacer()
      }
      .padding(.vertical, 8)
      .padding(.horizontal, 12)
      .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
    }
    .buttonStyle(.plain)
  }
}

// MARK: - iPhone Quick Action Button

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

// MARK: - Custom Tile Bottom Sheet Content

struct CustomTileBottomSheetContent: View {
  @EnvironmentObject var locationManager: LocationManager
  @Binding var useCustomTiles: Bool

  var body: some View {
    VStack(spacing: 16) {
      // Toggle for custom tiles
      HStack {
        Label("Custom Tiles", systemImage: "map")
          .font(.headline)

        Spacer()

        Toggle("", isOn: $useCustomTiles)
          .labelsHidden()
      }

      // Quick actions row
      HStack(spacing: 20) {
        ForEach(quickActions.indices, id: \.self) { index in
          QuickActionButton(
            icon: quickActions[index].icon,
            title: quickActions[index].title,
            action: quickActions[index].action
          )
        }
      }

      Spacer()
    }
  }

  private var quickActions: [QuickAction] {
    [
      QuickAction(icon: "location.fill", title: "My Location") {
        locationManager.requestLocation()
      },
      QuickAction(icon: "car.fill", title: "Directions") {
        // TODO: Open directions from current location
      },
      QuickAction(icon: "star.fill", title: "Favorites") {
        // TODO: Show favorites
      },
      QuickAction(icon: "clock.fill", title: "Recents") {
        // TODO: Show recent locations
      },
    ]
  }
}
