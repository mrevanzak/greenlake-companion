//
//  UrgencyLabel.swift
//  greenlake-companion
//
//  Created by Savio Enoson on 01/09/25.
//

import SwiftUI

enum UrgencyLabel: String, CaseIterable, Identifiable, DisplayableParameter {
  case overdue = "Terlambat"
  case short = "Segera"
  case normal = "Minggu Ini"
  case long = "> 1 Minggu"
  
  var id: String { self.rawValue }
  
  var displayName: String {
    switch self {
    case .overdue: return "Terlambat"
    case .short: return "Segera"
    case .normal: return "Minggu Ini"
    case .long: return "> 1 Minggu"
    }
  }
  
  var displayColor: Color {
    switch self {
      case .overdue: return .red
      case .short: return .orange
      case .normal: return .blue
      case .long: return .primary
    }
  }
}
