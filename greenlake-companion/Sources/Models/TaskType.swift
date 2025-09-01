//
//  TaskType.swift
//  greenlake-companion
//
//  Created by Savio Enoson on 01/09/25.
//


enum TaskType: String, CaseIterable, Identifiable {
  case major = "Major"
  case minor = "Minor"
  
  var id: String { self.rawValue }
}
