//
//  TaskListResponse.swift
//  greenlake-companion
//
//  Created by Akmal Ariq on 14/09/25.
//

import Foundation

// MARK: - Task
struct PlantTask: Codable {
    let id: String
    let author: String
    let taskName: String
    let status: String
    let urgency: String
    let plantName: String
    let dueDate: Date

    enum CodingKeys: String, CodingKey {
        case id
        case author
        case taskName = "taskName"
        case status
        case urgency
        case plantName = "plant_name"
        case dueDate = "due_date"
    }
}
