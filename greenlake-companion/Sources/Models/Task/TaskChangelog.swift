//
//  TaskChangelog.swift
//  greenlake-companion
//
//  Created by Savio Enoson on 02/09/25.
//

import Foundation

// MARK: - TimelineWrapper

struct TimelineWrapper: Codable {
    let id: UUID
    let taskName: String
    let plant_name: String
    let author: String
    let description: String
    let location: String
    let status: String
    let urgency: String
    let due_date: Date
    let createdAt: Date
    let timeline: [TaskChangelog]
}

// MARK: - TaskChangelog

struct TaskChangelog: Identifiable, Codable, Hashable {
    let id = UUID()  // Local identifier
    let fromStatus: String?
    let toStatus: String
    let note: String
    let author: String
    let createdAt: Date
    let photos: [Photo]

    // Computed properties
    var description: String? {
        note
    }

    var toStatusEnum: TaskStatus {
        TaskStatus(rawValue: toStatus) ?? .diajukan
    }

    var fromStatusEnum: TaskStatus? {
        guard let fromStatus else { return nil }
        return TaskStatus(rawValue: fromStatus)
    }
}

// MARK: - Photo Model

struct Photo: Codable, Hashable {
    let imageUrl: String
    let thumbnailUrl: String
}
