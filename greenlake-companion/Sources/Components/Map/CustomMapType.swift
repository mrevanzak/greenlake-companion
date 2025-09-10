//
//  CustomMapType.swift
//  greenlake-companion
//
//  Created by Theodore Michael Budiono on 09/09/25.
//

import MapKit
import SwiftUI

enum CustomMapType: String, CaseIterable {
  case standard = "Standard"
  case satellite = "Satellite"
  case hybrid = "Hybrid"

  var mkMapType: MKMapType {
    switch self {
    case .standard: return .standard
    case .satellite: return .satellite
    case .hybrid: return .hybrid
    }
  }

  var icon: String {
    switch self {
    case .standard: return "map"
    case .satellite: return "globe.americas"
    case .hybrid: return "map.fill"
    }
  }
}

struct MapTypeControl: View {
  @StateObject private var displayVM = MapDisplayViewModel.shared

  var body: some View {
    VStack(spacing: 4) {
      ForEach(CustomMapType.allCases, id: \.self) { type in
        Button(action: { displayVM.setMapType(type.mkMapType) }) {
          Image(systemName: type.icon)
            .font(.system(size: 20, weight: .semibold))
            .foregroundColor(
              displayVM.mapType == type.mkMapType ? .primary : .secondary.opacity(0.5)
            )
            .padding(10)
            .background(Color.clear)
        }
        .accessibilityLabel("\(type.rawValue) map type")
      }
    }
    .frame(width: 46)
    .padding(.vertical, 4)
    .background(.thinMaterial)
    .clipShape(Capsule())
    .shadow(color: .black.opacity(0.08), radius: 14, x: 0, y: 0)

  }
}
