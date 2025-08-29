//
//  MapViewRepresentable.swift
//  greenlake-companion
//
//  Created by AI Assistant on 21/08/25.
//

import CoreLocation
import MapKit
import SwiftUI

/// SwiftUI wrapper for MKMapView
struct MapViewRepresentable: UIViewRepresentable {
  @ObservedObject var locationManager: LocationManager
  @Binding var plants: [PlantInstance]
  @Binding var selectedPlant: PlantInstance?

  // MARK: - Initialization

  /// Initialize MapViewRepresentable
  /// - Parameters:
  ///   - locationManager: Location manager for user location tracking
  ///   - pins: Binding to the array of map pins
  ///   - selectedPin: Binding to the currently selected pin
  init(
    locationManager: LocationManager,
    plants: Binding<[PlantInstance]>,
    selectedPlant: Binding<PlantInstance?>
  ) {
    self.locationManager = locationManager
    self._plants = plants
    self._selectedPlant = selectedPlant
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
    // Update annotations when plants change
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

  /// Update map annotations when plants change
  private func updateAnnotations(on mapView: MKMapView) {
    // Remove existing annotations
    let existingAnnotations = mapView.annotations.filter { !($0 is MKUserLocation) }
    mapView.removeAnnotations(existingAnnotations)

    // Add new plant annotations
    let annotations = plants.map { PlantAnnotation(plant: $0) }
    mapView.addAnnotations(annotations)
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

    /// Handle long press gesture to add new plants
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
      guard gesture.state == .began else { return }

      let mapView = gesture.view as! MKMapView
      let point = gesture.location(in: mapView)
      let coordinate = mapView.convert(point, toCoordinateFrom: mapView)

      // Create a new plant at the pressed location
      let newPlant = PlantInstance(
        coordinate: coordinate,
        name: nil,
        type: .tree
      )

      // Add the new plant to the array
      parent.plants.append(newPlant)

      // Provide haptic feedback
      let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
      impactFeedback.impactOccurred()
    }

    // MARK: - MKMapViewDelegate

    /// Configure annotation views for plants
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
      // Don't customize user location annotation
      guard !(annotation is MKUserLocation) else { return nil }

      // Check if this is one of our plant annotations
      guard let plantAnno = annotation as? PlantAnnotation else { return nil }

      let identifier = "PlantAnnotation"
      let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)

      // Configure the pin appearance
      switch plantAnno.plant.type {
      case .tree: annotationView.pinTintColor = .systemGreen
      case .groundCover: annotationView.pinTintColor = .systemTeal
      case .bush: annotationView.pinTintColor = .systemMint
      }
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
      guard let plantAnno = view.annotation as? PlantAnnotation else { return }

      // Set the selected plant by resolving back to value model
      if let plant = parent.plants.first(where: { $0.id == plantAnno.id }) {
        parent.selectedPlant = plant
      }

      // Provide haptic feedback
      let impactFeedback = UIImpactFeedbackGenerator(style: .light)
      impactFeedback.impactOccurred()
    }

    /// Handle selection of annotations
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
      guard let plantAnno = view.annotation as? PlantAnnotation else { return }
      if let plant = parent.plants.first(where: { $0.id == plantAnno.id }) {
        parent.selectedPlant = plant
      }
    }

    /// Handle deselection of annotations
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
      parent.selectedPlant = nil
    }
  }
}
