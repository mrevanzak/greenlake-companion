//
//  PlantAnnotation.swift
//  greenlake-companion
//
//  Created by AI Assistant on 28/08/25.
//

import CoreLocation
import Foundation
import MapKit

/// Lightweight MKAnnotation bridge that wraps a value-type PlantInstance
final class PlantAnnotation: NSObject, MKAnnotation {
  let id: UUID
  let plant: PlantInstance
  dynamic var coordinate: CLLocationCoordinate2D

  var title: String? { plant.name ?? "Unnamed Plant" }
  var subtitle: String? { plant.type.displayName }

  /// Check if this annotation represents a temporary plant
  var isTemporary: Bool {
    // Temporary plants are those created very recently (within last few seconds)
    // This is a simple heuristic - in a real app you might want a more robust approach
    return plant.createdAt.timeIntervalSinceNow > -5
  }

  init(plant: PlantInstance) {
    self.id = plant.id
    self.plant = plant
    self.coordinate = plant.coordinate
    super.init()
  }
}
