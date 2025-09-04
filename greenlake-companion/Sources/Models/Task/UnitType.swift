//
//  TaskType 2.swift
//  greenlake-companion
//
//  Created by Akmal Ariq on 04/09/25.
//

enum UnitType: String, CaseIterable, Identifiable, DisplayableParameter, Codable {
  case m2 = "Meter Persegi (m²)"
  case cm2 = "Centimeter Persegi (cm²)"
  case ha = "Hektar (ha)"
  case m = "Meter (m"
  case cm = "Centimeter (cm)"

  var id: String { self.rawValue }

  var displayName: String {
    switch self {
    case .m2: return "Meter Persegi (m²)"
    case .cm2: return "Centimeter Persegi (cm²)"
    case .ha: return "Hektar (ha)"
    case .m: return "Meter (m)"
    case .cm: return "Centimeter (cm)"
    }
  }
}
