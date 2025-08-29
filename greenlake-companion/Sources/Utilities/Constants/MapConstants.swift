import CoreLocation
import MapKit

// MARK: - Map Constants

/// Constants for map configuration and boundaries
enum MapConstants {
  /// Central point for the map view and boundaries
  static let centerCoordinate = CLLocationCoordinate2D(
    latitude: -7.309203,
    longitude: 112.656577
  )

  /// Maximum distance users can navigate from center (in coordinate degrees)
  /// Approximately 10km radius from center
  static let boundaryLatitudeDelta: CLLocationDegrees = 0.10  // ~10km north/south
  static let boundaryLongitudeDelta: CLLocationDegrees = 0.10  // ~10km east/west

  /// Initial map region span
  static let initialRegionSpan = MKCoordinateSpan(
    latitudeDelta: 0.01,  // ~1km north/south - city level zoom
    longitudeDelta: 0.01  // ~1km east/west - city level zoom
  )

  /// Complete initial region for map setup
  static var initialRegion: MKCoordinateRegion {
    MKCoordinateRegion(center: centerCoordinate, span: initialRegionSpan)
  }

  /// Camera boundary region to limit user navigation
  static var boundaryRegion: MKCoordinateRegion {
    MKCoordinateRegion(
      center: centerCoordinate,
      span: MKCoordinateSpan(
        latitudeDelta: boundaryLatitudeDelta * 2,
        longitudeDelta: boundaryLongitudeDelta * 2
      )
    )
  }

  /// Camera boundary object for MKMapView
  static var cameraBoundary: MKMapView.CameraBoundary? {
    MKMapView.CameraBoundary(coordinateRegion: boundaryRegion)
  }
}
