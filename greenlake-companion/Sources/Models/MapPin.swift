//
//  MapPin.swift
//  greenlake-companion
//
//  Created by AI Assistant on 21/08/25.
//

import CoreLocation
import Foundation
import MapKit
import UIKit

/// Represents a pin that can be placed on the map
class MapPin: NSObject, Identifiable {
  /// Unique identifier for the pin
  let id = UUID()

  /// Coordinate where the pin is placed
  let coordinate: CLLocationCoordinate2D

  /// Title of the pin (optional)
  let title: String?

  /// Subtitle of the pin (optional)
  let subtitle: String?

  /// Date when the pin was created
  let createdAt: Date

  /// Custom annotation color (optional)
  let pinColor: PinColor

  /// Available pin colors
  enum PinColor: String, CaseIterable {
    case red = "red"
    case green = "green"
    case blue = "blue"
    case purple = "purple"
    case orange = "orange"

    /// Convert to UIColor for custom annotations
    var uiColor: UIColor {
      switch self {
      case .red: return .systemRed
      case .green: return .systemGreen
      case .blue: return .systemBlue
      case .purple: return .systemPurple
      case .orange: return .systemOrange
      }
    }
  }

  // MARK: - Initialization

  /// Initialize a new map pin
  /// - Parameters:
  ///   - coordinate: The coordinate where the pin should be placed
  ///   - title: Optional title for the pin
  ///   - subtitle: Optional subtitle for the pin
  ///   - pinColor: Color of the pin (defaults to red)
  init(
    coordinate: CLLocationCoordinate2D,
    title: String? = nil,
    subtitle: String? = nil,
    pinColor: PinColor = .red
  ) {
    self.coordinate = coordinate
    self.title = title
    self.subtitle = subtitle
    self.createdAt = Date()
    self.pinColor = pinColor
    super.init()
  }
}

// MARK: - MKAnnotation Conformance

extension MapPin: MKAnnotation {
  // The coordinate property is already defined in the class
  // This extension just makes it conform to MKAnnotation protocol
}
