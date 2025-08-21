//
//  CLLocationCoordinate2D+Extensions.swift
//  greenlake-companion
//
//  Created by AI Assistant on 21/08/25.
//

import CoreLocation

// MARK: - Extensions

extension CLLocationCoordinate2D {
  var location: CLLocation {
    return CLLocation(latitude: latitude, longitude: longitude)
  }
}
