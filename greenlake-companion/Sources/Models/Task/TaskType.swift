//
//  TaskType.swift
//  greenlake-companion
//
//  Created by Savio Enoson on 01/09/25.
//


enum TaskType: String, CaseIterable, Identifiable, DisplayableParameter {
  case major = "Major"
  case minor = "Minor"
  
  var id: String { self.rawValue }
  
  var displayName: String {
    switch self {
      case .major : return "Major"
      case .minor : return "Minor"
    }
  }
}
