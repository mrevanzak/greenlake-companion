//
//  TaskStatus.swift
//  greenlake-companion
//
//  Created by Savio Enoson on 01/09/25.
//

import SwiftUI

enum TaskStatus: String, CaseIterable, Identifiable {
  case aktif = "Aktif"
  case diajukan = "Diajukan"
  case diperiksa = "Diperiksa"
  case selesai = "Selesai"
  case terdenda = "Terdenda"
  case dialihkan = "Dialihkan"
  
  var id: String { self.rawValue }
  
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
    case .terdenda:
      return .red
    case .dialihkan:
      return .purple
    }
  }
}
