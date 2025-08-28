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

/// SwiftUI wrapper for MKMapView
struct MapViewRepresentable: UIViewRepresentable {
  @ObservedObject var locationManager: LocationManager
  @Binding var pins: [MapPin]
  @Binding var selectedPin: MapPin?

  // MARK: - Initialization

  /// Initialize MapViewRepresentable
  /// - Parameters:
  ///   - locationManager: Location manager for user location tracking
  ///   - pins: Binding to the array of map pins
  ///   - selectedPin: Binding to the currently selected pin
  init(
    locationManager: LocationManager,
    pins: Binding<[MapPin]>,
    selectedPin: Binding<MapPin?>
  ) {
    self.locationManager = locationManager
    self._pins = pins
    self._selectedPin = selectedPin
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

    // Add long press gesture recognizer
    addLongPressGesture(to: mapView, context: context)

    return mapView
  }

  func updateUIView(_ mapView: MKMapView, context: Context) {
    // Update annotations when pins change
    updateAnnotations(on: mapView)

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

  /// Add long press gesture recognizer to the map
  private func addLongPressGesture(to mapView: MKMapView, context: Context) {
    let longPressGesture = UILongPressGestureRecognizer(
      target: context.coordinator,
      action: #selector(Coordinator.handleLongPress(_:))
    )
    longPressGesture.minimumPressDuration = 0.5
    mapView.addGestureRecognizer(longPressGesture)
  }

  /// Update map annotations when pins change
  private func updateAnnotations(on mapView: MKMapView) {
    // Remove existing annotations
    let existingAnnotations = mapView.annotations.filter { !($0 is MKUserLocation) }
    mapView.removeAnnotations(existingAnnotations)

    // Add new pin annotations
    mapView.addAnnotations(pins)
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

    // MARK: - Long Press Handling

    /// Handle long press gesture to add new pins
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
      guard gesture.state == .began else { return }

      let mapView = gesture.view as! MKMapView
      let point = gesture.location(in: mapView)
      let coordinate = mapView.convert(point, toCoordinateFrom: mapView)

      // Create a new pin at the pressed location
      let newPin = MapPin(
        coordinate: coordinate,
        title: "Pin \(parent.pins.count + 1)",
        subtitle: "Added on \(Date().formatted(date: .abbreviated, time: .shortened))"
      )

      // Add the new pin to the array
      parent.pins.append(newPin)

      // Provide haptic feedback
      let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
      impactFeedback.impactOccurred()
    }

    // MARK: - MKMapViewDelegate

    /// Configure annotation views for pins
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
      // Don't customize user location annotation
      guard !(annotation is MKUserLocation) else { return nil }

      // Check if this is one of our custom pins
      guard let mapPin = annotation as? MapPin else { return nil }

      let identifier = "MapPin"
      let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)

      // Configure the pin appearance
      annotationView.pinTintColor = mapPin.pinColor.uiColor
      annotationView.canShowCallout = true
      annotationView.calloutOffset = CGPoint(x: 0, y: -4)

      // Add a detail disclosure button to the callout
      let detailButton = UIButton(type: .detailDisclosure)
      annotationView.rightCalloutAccessoryView = detailButton

      return annotationView
    }

    /// Handle tap on annotation callout accessory
    func mapView(
      _ mapView: MKMapView, annotationView view: MKAnnotationView,
      calloutAccessoryControlTapped control: UIControl
    ) {
      guard let mapPin = view.annotation as? MapPin else { return }

      // Set the selected pin
      parent.selectedPin = mapPin

      // Provide haptic feedback
      let impactFeedback = UIImpactFeedbackGenerator(style: .light)
      impactFeedback.impactOccurred()
    }

    /// Handle selection of annotations
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
      guard let mapPin = view.annotation as? MapPin else { return }
      parent.selectedPin = mapPin
    }

    /// Handle deselection of annotations
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
      parent.selectedPin = nil
    }
  }
}
