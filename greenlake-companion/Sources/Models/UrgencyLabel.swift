//
//  UrgencyLabel.swift
//  greenlake-companion
//
//  Created by Savio Enoson on 01/09/25.
//


enum UrgencyLabel: String, CaseIterable, Identifiable {
  case segera = "Segera"
  case normal = "Normal"
  
  var id: String { self.rawValue }
}