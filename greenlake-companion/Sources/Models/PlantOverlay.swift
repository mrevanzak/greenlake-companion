//
//  PlantOverlay.swift
//  greenlake-companion
//
//  Created by AI Assistant on 02/09/25.
//

import Foundation
import MapKit

/// MKPolygon subclass that carries a domain `plantId` for reverse lookup on selection
final class PlantPolygon: MKPolygon {
  private(set) var plantId: UUID = UUID()

  /// Convenience initializer that assigns geometry and associated plant identifier
  convenience init(plantId: UUID, coordinates: [CLLocationCoordinate2D]) {
    self.init(coordinates: coordinates, count: coordinates.count)
    self.plantId = plantId
  }
}

/// MKPolyline subclass that carries a domain `plantId` for reverse lookup on selection
final class PlantPolyline: MKPolyline {
  private(set) var plantId: UUID = UUID()

  /// Convenience initializer that assigns geometry and associated plant identifier
  convenience init(plantId: UUID, coordinates: [CLLocationCoordinate2D]) {
    self.init(coordinates: coordinates, count: coordinates.count)
    self.plantId = plantId
  }
}
