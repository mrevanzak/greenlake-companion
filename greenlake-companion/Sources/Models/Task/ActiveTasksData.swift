//
//  ActiveTasksData.swift
//  greenlake-companion
//
//  Created by Akmal Ariq on 12/09/25.
//


import Foundation
import SwiftUI // ⬅️ Required for using Color

// MARK: - Root Data Model
struct ActiveTasksData: Codable {
    let activeTask: Int
    let diajukanTask: Int
    let diperiksaTask: Int
    let approachingDeadline: Int
    let tasks: [ActiveTaskList]
}

// MARK: - Task Model
struct ActiveTaskList: Codable, Identifiable {
    let id: String
    let taskName: String
    let status: String
    let dueDate: Date
    let location: String
    let plantName: String
}

// MARK: - Computed Properties for UI
extension ActiveTaskList {
    var title: String { taskName }
    var urgencyLabel: TaskUrgency {
        switch status.lowercased() {
        case "diperiksa": return .warning
        case "diajukan": return .urgent
        default: return .normal
        }
    }
    var urgencyStatus: TaskUrgency {
        urgencyLabel
    }
}

// MARK: - Enum for Task Urgency
enum TaskUrgency {
    case urgent
    case warning
    case normal
    var displayName: String {
        switch self {
        case .urgent: return "Urgent"
        case .warning: return "Warning"
        case .normal: return "Normal"
        }
    }

    var displayColor: Color {
        switch self {
        case .urgent: return .red
        case .warning: return .orange
        case .normal: return .green
        }
    }
}
