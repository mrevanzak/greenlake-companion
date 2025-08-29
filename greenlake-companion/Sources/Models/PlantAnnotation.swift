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

  init(plant: PlantInstance) {
    self.id = plant.id
    self.plant = plant
    self.coordinate = plant.coordinate
    super.init()
  }
}
