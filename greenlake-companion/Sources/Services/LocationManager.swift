//
//  LocationManager.swift
//  greenlake-companion
//
//  Created by AI Assistant on 21/08/25.
//

import CoreLocation
import Foundation
import SwiftUI

/// LocationManager handles all location services and authorization for the app
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
  @Published var location: CLLocation?
  @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
  @Published var heading: CLHeading?
  @Published var isLocationEnabled: Bool = false

  private let manager = CLLocationManager()

  override init() {
    super.init()
    setupLocationManager()
  }

  private func setupLocationManager() {
    manager.delegate = self
    manager.desiredAccuracy = kCLLocationAccuracyBest
    manager.distanceFilter = 10  // Update every 10 meters
    authorizationStatus = manager.authorizationStatus

    // Request initial authorization
    if authorizationStatus == .notDetermined {
      manager.requestWhenInUseAuthorization()
    }
  }

  // MARK: - Public Methods

  func requestLocation() {
    guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
    else {
      manager.requestWhenInUseAuthorization()
      return
    }

    manager.requestLocation()
  }

  func startTracking() {
    guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways
    else {
      return
    }

    manager.startUpdatingLocation()
    manager.startUpdatingHeading()
    isLocationEnabled = true
  }

  func stopTracking() {
    manager.stopUpdatingLocation()
    manager.stopUpdatingHeading()
    isLocationEnabled = false
  }

  // MARK: - CLLocationManagerDelegate

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let newLocation = locations.last else { return }

    // Filter out old or inaccurate readings
    let age = newLocation.timestamp.timeIntervalSinceNow
    if abs(age) > 5.0 { return }  // Ignore readings older than 5 seconds
    if newLocation.horizontalAccuracy > 50 { return }  // Ignore inaccurate readings

    DispatchQueue.main.async {
      self.location = newLocation
    }
  }

  func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
    guard newHeading.headingAccuracy > 0 else { return }

    DispatchQueue.main.async {
      self.heading = newHeading
    }
  }

  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    DispatchQueue.main.async {
      self.authorizationStatus = manager.authorizationStatus

      switch self.authorizationStatus {
      case .authorizedWhenInUse, .authorizedAlways:
        self.startTracking()
      case .denied, .restricted:
        self.stopTracking()
      case .notDetermined:
        break
      @unknown default:
        break
      }
    }
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("Location manager failed with error: \(error.localizedDescription)")
  }
}
