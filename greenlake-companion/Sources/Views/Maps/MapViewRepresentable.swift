//
//  MapViewRepresentable.swift
//  greenlake-companion
//
//  Created by AI Assistant on 21/08/25.
//

import CoreLocation
import MapKit
import SwiftUI

// MARK: - Map Constants

/// Constants for map configuration and boundaries
private enum MapConstants {
  /// Central point for the map view and boundaries
  static let centerCoordinate = CLLocationCoordinate2D(
    latitude: 40.774669555422349,
    longitude: -73.964170794293238
  )

  /// Maximum distance users can navigate from center (in coordinate degrees)
  /// Approximately 10km radius from center
  static let boundaryLatitudeDelta: CLLocationDegrees = 0.10  // ~10km north/south
  static let boundaryLongitudeDelta: CLLocationDegrees = 0.10  // ~10km east/west

  /// Initial map region span
  static let initialRegionSpan = MKCoordinateSpan(
    latitudeDelta: 0.16405544070813249,
    longitudeDelta: 0.1232528799585566
  )

  /// Minimum zoom distance (closest zoom level)
  static let minZoomDistance: CLLocationDistance = 5000  // ~5km

  /// Maximum zoom distance (furthest zoom level)
  static let maxZoomDistance: CLLocationDistance = 50000  // ~50km

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

  /// Zoom range for custom tiles
  static var customTileZoomRange: MKMapView.CameraZoomRange? {
    MKMapView.CameraZoomRange(
      minCenterCoordinateDistance: minZoomDistance,
      maxCenterCoordinateDistance: maxZoomDistance
    )
  }
}

/// SwiftUI wrapper for MKMapView with support for custom tile overlays
struct MapViewRepresentable: UIViewRepresentable {
  @ObservedObject var locationManager: LocationManager

  // MARK: - Custom Tile Properties

  /// Enable custom tiles instead of standard map tiles
  let useCustomTiles: Bool

  // MARK: - Initialization

  /// Initialize MapViewRepresentable with optional custom tile support
  /// - Parameters:
  ///   - locationManager: Location manager for user location tracking
  ///   - useCustomTiles: Whether to use custom tiles instead of standard map tiles
  ///   - customTileURL: Optional base URL for external tile server
  init(locationManager: LocationManager, useCustomTiles: Bool = false, customTileURL: String? = nil)
  {
    self.locationManager = locationManager
    self.useCustomTiles = useCustomTiles
  }

  // MARK: - UIViewRepresentable Implementation

  func makeUIView(context: Context) -> MKMapView {
    let mapView = MKMapView()

    // Set delegate for tile overlay rendering
    mapView.delegate = context.coordinator

    // Configure map appearance
    configureMapAppearance(mapView)

    // Configure user interaction
    configureUserInteraction(mapView)

    // Set initial region
    setupInitialRegion(mapView)

    // Add custom tile overlay if enabled
    if useCustomTiles {
      setupCustomTiles(on: mapView)
    }

    return mapView
  }

  func updateUIView(_ mapView: MKMapView, context: Context) {
    // Handle custom tiles overlay changes
    updateTileOverlay(mapView)

    // Update user location tracking
    // if let location = locationManager.location {
    //   let region = MKCoordinateRegion(
    //     center: location.coordinate,
    //     span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    //   )
    //   mapView.setRegion(region, animated: true)
    // }
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  // MARK: - Private Configuration Methods

  /// Configure map visual appearance settings
  private func configureMapAppearance(_ mapView: MKMapView) {
    mapView.showsUserLocation = true
    mapView.userTrackingMode = .none
    mapView.mapType = .standard
    mapView.showsCompass = false
    mapView.showsScale = false
    mapView.showsTraffic = false
  }

  /// Configure user interaction capabilities
  private func configureUserInteraction(_ mapView: MKMapView) {
    mapView.isZoomEnabled = true
    mapView.isScrollEnabled = true
    mapView.isRotateEnabled = true
    mapView.isPitchEnabled = true
  }

  /// Set up the initial map region
  private func setupInitialRegion(_ mapView: MKMapView) {
    mapView.setRegion(MapConstants.initialRegion, animated: false)

    // Set camera boundary to limit user navigation area
    setCameraBoundary(on: mapView)
  }

  /// Configure custom tile overlay with zoom constraints
  private func setupCustomTiles(on mapView: MKMapView) {
    addCustomTileOverlay(to: mapView)
  }

  /// Update tile overlay based on useCustomTiles state
  private func updateTileOverlay(_ mapView: MKMapView) {
    let hasCustomOverlay = mapView.overlays.contains { $0 is CustomTileOverlay }

    if useCustomTiles && !hasCustomOverlay {
      addCustomTileOverlay(to: mapView)
    } else if !useCustomTiles && hasCustomOverlay {
      removeCustomTileOverlay(from: mapView)
    }
  }

  /// Add custom tile overlay and configure zoom constraints
  private func addCustomTileOverlay(to mapView: MKMapView) {
    let overlay = createCustomTileOverlay()
    setCustomTileZoomConstraints(on: mapView)
    mapView.addOverlay(overlay, level: .aboveLabels)
  }

  /// Remove custom tile overlay and reset zoom constraints
  private func removeCustomTileOverlay(from mapView: MKMapView) {
    let customOverlays = mapView.overlays.filter { $0 is CustomTileOverlay }
    mapView.removeOverlays(customOverlays)
    resetZoomConstraints(on: mapView)
  }

  /// Create a custom tile overlay with consistent configuration
  private func createCustomTileOverlay() -> CustomTileOverlay {
    return CustomTileOverlay(fallbackTile: "greenlake-default")
  }

  /// Set zoom constraints optimized for custom tiles
  private func setCustomTileZoomConstraints(on mapView: MKMapView) {
    mapView.cameraZoomRange = MapConstants.customTileZoomRange
  }

  /// Reset zoom constraints to default (no constraints)
  private func resetZoomConstraints(on mapView: MKMapView) {
    mapView.cameraZoomRange = MKMapView.CameraZoomRange()
  }

  /// Set camera boundary to limit the area where users can navigate
  private func setCameraBoundary(on mapView: MKMapView) {
    mapView.cameraBoundary = MapConstants.cameraBoundary
  }
}

// MARK: - Coordinator for MKMapViewDelegate

extension MapViewRepresentable {
  /// Coordinator class implementing MKMapViewDelegate for tile overlay rendering
  class Coordinator: NSObject, MKMapViewDelegate {
    var parent: MapViewRepresentable

    init(_ parent: MapViewRepresentable) {
      self.parent = parent
    }

    /// Provide renderer for tile overlays
    /// - Parameters:
    ///   - mapView: The map view requesting the renderer
    ///   - overlay: The overlay requiring rendering
    /// - Returns: Appropriate renderer for the overlay type
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
      if let tileOverlay = overlay as? CustomTileOverlay {
        return MKTileOverlayRenderer(tileOverlay: tileOverlay)
      }
      return MKOverlayRenderer(overlay: overlay)
    }
  }
}
