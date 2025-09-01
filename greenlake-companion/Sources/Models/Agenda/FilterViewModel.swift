//
//  FilterViewModel.swift
//  greenlake-companion
//
//  Created by Savio Enoson on 01/09/25.
//


import Foundation
import SwiftUI


class FilterViewModel: ObservableObject {
    @Published var taskType: [TaskType] = TaskType.allCases
    @Published var urgency: [UrgencyLabel] = UrgencyLabel.allCases
    @Published var plantType: [PlantType] = PlantType.allCases
    @Published var status: [TaskStatus] = TaskStatus.allCases
    @Published var startDate: Date = Date()
    @Published var endDate: Date = Date()
    
    @Published var sortKey: SortKey = .dateCreated
    @Published var sortOrder: SortingState = .descending
    
    var isDefaultState: Bool {
        // Check if all filter arrays contain all possible cases.
        let areArraysDefault = taskType.count == TaskType.allCases.count &&
                               urgency.count == UrgencyLabel.allCases.count &&
                               plantType.count == PlantType.allCases.count &&
                               status.count == TaskStatus.allCases.count

        // Check if the date range has not been set.
        let areDatesDefault = startDate == Date() && endDate == Date()

        // Check if sorting is at its default.
        let isSortingDefault = sortKey == .dateCreated && sortOrder == .descending

        // Return true only if all conditions are met.
        return areArraysDefault && areDatesDefault && isSortingDefault
    }

    func resetFilters() {
        taskType = TaskType.allCases
        urgency = UrgencyLabel.allCases
        plantType = PlantType.allCases
        status = TaskStatus.allCases
        startDate = Date()
        endDate = Date()
        sortKey = .dateCreated
        sortOrder = .descending
    }
}