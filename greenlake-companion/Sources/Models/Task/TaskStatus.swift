//
//  TaskStatus.swift
//  greenlake-companion
//
//  Created by Savio Enoson on 01/09/25.
//

import SwiftUI

enum TaskStatus: String, CaseIterable, Identifiable, DisplayableParameter, Codable {
  case diajukan = "Diajukan"
  case aktif = "Aktif"
  case diperiksa = "Diperiksa"
  case selesai = "Selesai"
  //  case terdenda = "Terdenda"
  case dialihkan = "Dialihkan"
  
  var id: String { self.rawValue }
  
  var displayName: String {
    switch self {
    case .aktif: return "Aktif"
    case .diajukan: return "Diajukan"
    case .diperiksa: return "Diperiksa"
    case .selesai: return "Selesai"
      //    case .terdenda: return "Terdenda"
    case .dialihkan: return "Dialihkan"
    }
  }
  
  // Add this computed property
  var displayColor: Color {
    switch self {
    case .aktif:
      return .blue
    case .diajukan:
      return .secondary
    case .diperiksa:
      return .orange
    case .selesai:
      return .green
      //    case .terdenda:
      //      return .red
    case .dialihkan:
      return .purple
    }
  }
  
  var iconName: String {
    switch self {
    case .aktif: return "gearshape"
    case .diajukan: return "ellipsis"
    case .diperiksa: return "magnifyingglass"
    case .selesai: return "checkmark"
      //    case .terdenda: return "exclamationmark"
    case .dialihkan: return "arrowshape.turn.up.right"
    }
  }
}
