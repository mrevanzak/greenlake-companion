import MapKit
import SwiftUI

final class MapDisplayViewModel: ObservableObject {
  static let shared = MapDisplayViewModel()

  @AppStorage("mapType") private var storedMapType: Int = Int(MKMapType.standard.rawValue)
  @Published var mapType: MKMapType = .standard

  private init() {
    self.mapType = MKMapType(rawValue: UInt(self.storedMapType)) ?? .standard
  }

  func setMapType(_ type: MKMapType) {
    guard mapType != type else { return }
    mapType = type
    storedMapType = Int(type.rawValue)
  }
}
