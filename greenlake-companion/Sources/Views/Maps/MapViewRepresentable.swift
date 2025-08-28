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

/// SwiftUI wrapper for MKMapView
struct MapViewRepresentable: UIViewRepresentable {
  @ObservedObject var locationManager: LocationManager

  // MARK: - Initialization

  /// Initialize MapViewRepresentable
  /// - Parameter locationManager: Location manager for user location tracking
  init(locationManager: LocationManager) {
    self.locationManager = locationManager
  }

  // MARK: - UIViewRepresentable Implementation

  func makeUIView(context: Context) -> MKMapView {
    let mapView = MKMapView()

    // Set delegate for map interactions
    mapView.delegate = context.coordinator

    // Configure map appearance
    configureMapAppearance(mapView)

    // Configure user interaction
    configureUserInteraction(mapView)

    // Set initial region
    setupInitialRegion(mapView)

    return mapView
  }

  func updateUIView(_ mapView: MKMapView, context: Context) {
    // Update user location tracking if needed
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

  /// Set camera boundary to limit the area where users can navigate
  private func setCameraBoundary(on mapView: MKMapView) {
    mapView.cameraBoundary = MapConstants.cameraBoundary
  }
}

// MARK: - Coordinator for MKMapViewDelegate

extension MapViewRepresentable {
  /// Coordinator class implementing MKMapViewDelegate
  class Coordinator: NSObject, MKMapViewDelegate {
    var parent: MapViewRepresentable

    init(_ parent: MapViewRepresentable) {
      self.parent = parent
    }
  }
}
