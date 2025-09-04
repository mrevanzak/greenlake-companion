//
//  TaskDTO.swift
//  greenlake-companion
//
//  Created by AI Assistant on 05/01/25.
//

import Foundation

/// Request model for creating a new task
struct CreateTaskRequest: Codable {
  let taskName: String
  let urgency: TaskType
  let dueDate: Date
  let plantId: UUID
  let area: String?
  let unit: String?
  let description: String?
  let location: String

  enum CodingKeys: String, CodingKey {
    case taskName
    case urgency
    case dueDate = "due_date"
    case plantId = "plant_id"
    case area
    case unit
    case description
    case location
  }

  init(
    taskName: String,
    urgency: TaskType,
    dueDate: Date,
    plantId: UUID,
    area: String? = nil,
    unit: String? = nil,
    description: String? = nil,
    location: String,
    conditions: [String]? = nil
  ) {
    self.taskName = taskName
    self.urgency = urgency
    self.dueDate = dueDate
    self.plantId = plantId
    self.area = area
    self.unit = unit
    self.description = description
    self.location = location
  }
}

/// Response model for task creation
struct CreateTaskResponse: Codable {
  let id: UUID
  let taskName: String
  let urgency: TaskType
  let dueDate: Date
  let plantId: UUID
  let area: String?
  let unit: String?
  let description: String?
  let location: String
  let status: TaskStatus
  let createdAt: Date
  let updatedAt: Date

  enum CodingKeys: String, CodingKey {
    case id
    case taskName
    case urgency
    case dueDate = "due_date"
    case plantId = "plant_id"
    case area
    case unit
    case description
    case location
    case status
    case createdAt
    case updatedAt
  }
}

/// Request model for updating an existing task
struct UpdateTaskRequest: Codable {
  let taskName: String?
  let urgency: TaskType?
  let dueDate: Date?
  let description: String?
  let status: TaskStatus?

  enum CodingKeys: String, CodingKey {
    case taskName = "task_name"
    case urgency
    case dueDate = "due_date"
    case description
    case status
  }

  init(
    taskName: String? = nil,
    urgency: TaskType? = nil,
    dueDate: Date? = nil,
    description: String? = nil,
    status: TaskStatus? = nil
  ) {
    self.taskName = taskName
    self.urgency = urgency
    self.dueDate = dueDate
    self.description = description
    self.status = status
  }
}

// MARK: - Backend API Response Models

/// Image data model for task images from the backend API
struct TaskImage: Codable {
  let imageUrl: String
  let thumbnailUrl: String
  let uploadedBy: String
  let createdAt: Date

  enum CodingKeys: String, CodingKey {
    case imageUrl
    case thumbnailUrl
    case uploadedBy
    case createdAt
  }
}

/// Backend API response model for tasks that matches the actual API format
struct TaskResponse: Codable {
  let id: String
  let userId: Int
  let plantName: String
  let author: String
  let title: String
  let description: String?
  let status: String
  let urgency: String
  let plantType: String
  let dueDate: Date
  let createdAt: Date
  let updatedAt: Date
  let images: [TaskImage]

  enum CodingKeys: String, CodingKey {
    case id
    case userId
    case plantName = "plant_name"
    case author
    case title = "taskName"
    case description
    case status
    case urgency
    case plantType = "plant_type"
    case dueDate = "due_date"
    case createdAt
    case updatedAt
    case images
  }
}

// MARK: - Backend-to-Frontend Adapter

extension TaskResponse {
  /// Converts TaskResponse from backend API to LandscapingTask for UI consumption
  func toLandscapingTask() -> LandscapingTask {
    // Map status string to TaskStatus enum
    let taskStatus: TaskStatus
    switch status.lowercased() {
    case "diajukan":
      taskStatus = .diajukan
    case "aktif":
      taskStatus = .aktif
    case "diperiksa":
      taskStatus = .diperiksa
    case "selesai":
      taskStatus = .selesai
    case "terdenda":
      taskStatus = .terdenda
    case "dialihkan":
      taskStatus = .dialihkan
    default:
      taskStatus = .diajukan  // Default fallback
    }

    // Map urgency string to TaskType enum
    let taskType: TaskType
    switch urgency.lowercased() {
    case "major":
      taskType = .major
    case "minor":
      taskType = .minor
    default:
      taskType = .minor  // Default fallback
    }

    // Map plant type string to PlantType enum
    let mappedPlantType: PlantType
    switch self.plantType.lowercased() {
    case "tree":
      mappedPlantType = .tree
    case "ground_cover":
      mappedPlantType = .groundCover
    case "bush":
      mappedPlantType = .bush
    default:
      mappedPlantType = .tree  // Default fallback
    }

    return LandscapingTask(
      title: title,
      description: description ?? "",
      taskType: taskType,
      plantType: mappedPlantType,
      status: taskStatus,
      dueDate: dueDate,
      dateCreated: createdAt,
      dateModified: updatedAt,
      dateClosed: taskStatus == .selesai || taskStatus == .terdenda ? updatedAt : nil
    )
  }
}
