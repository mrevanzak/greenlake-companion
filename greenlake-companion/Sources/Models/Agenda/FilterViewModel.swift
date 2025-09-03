//
//  FilterViewModel.swift
//  greenlake-companion
//
//  Created by Savio Enoson on 01/09/25.
//


import Foundation
import SwiftUI


class FilterViewModel: ObservableObject {
  @Published var taskType: [TaskType] = []
  @Published var urgency: [UrgencyLabel] = []
  @Published var plantType: [PlantType] = []
  @Published var status: [TaskStatus] = []
  @Published var startDate: Date = Date()
  @Published var endDate: Date = Date()
  
  @Published var sortKey: SortKey = .dateCreated
  @Published var sortOrder: SortingState = .descending
  
  var isDefaultState: Bool {
    // Check if all filter arrays contain all possible cases.
    let areArraysDefault = taskType.count + urgency.count + plantType.count + status.count == 0
    
    // Check if the date range has not been set.
    let defaultDate = dateFormatter.string(from: Date())
    let areDatesDefault = dateFormatter.string(from: startDate) == defaultDate && dateFormatter.string(from: endDate) == defaultDate
    
    // Check if sorting is at its default.
    let isSortingDefault = sortKey == .dateCreated && sortOrder == .descending
    
    // Return true only if all conditions are met.
    return areArraysDefault && areDatesDefault && isSortingDefault
  }
  
  func resetFilters() {
    taskType = []
    urgency = []
    plantType = []
    status = []
    startDate = Date()
    endDate = Date()
    sortKey = .dateCreated
    sortOrder = .descending
  }
}
