//
//  MapViewRepresentable.swift
//  greenlake-companion
//
//  Created by AI Assistant on 21/08/25.
//

import CoreLocation
import MapKit
import SwiftUI

/// SwiftUI wrapper for MKMapView - simplified to just display map
struct MapViewRepresentable: UIViewRepresentable {
  @ObservedObject var locationManager: LocationManager

  func makeUIView(context: Context) -> MKMapView {
    let mapView = MKMapView()

    // Configure map appearance
    mapView.showsUserLocation = true
    mapView.userTrackingMode = .none
    mapView.mapType = .standard
    mapView.showsCompass = false
    mapView.showsScale = false
    mapView.showsTraffic = false

    // Enable user interaction
    mapView.isZoomEnabled = true
    mapView.isScrollEnabled = true
    mapView.isRotateEnabled = true
    mapView.isPitchEnabled = true

    // Set initial region (default to Cupertino)
    let initialRegion = MKCoordinateRegion(
      center: CLLocationCoordinate2D(latitude: 37.3230, longitude: -122.0322),
      span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    mapView.setRegion(initialRegion, animated: false)

    return mapView
  }

  func updateUIView(_ mapView: MKMapView, context: Context) {
    // Update user location tracking
    if let location = locationManager.location {
      let region = MKCoordinateRegion(
        center: location.coordinate,
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
      )
      mapView.setRegion(region, animated: true)
    }
  }
}
