//
//  TaskRequest.swift
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
  let description: String?
  let location: String
  let conditions: [String]?

  enum CodingKeys: String, CodingKey {
    case taskName = "task_name"
    case urgency
    case dueDate = "due_date"
    case plantId = "plant_id"
    case description
    case location
    case conditions
  }

  init(
    taskName: String,
    urgency: TaskType,
    dueDate: Date,
    plantId: UUID,
    description: String? = nil,
    location: String,
    conditions: [String]? = nil
  ) {
    self.taskName = taskName
    self.urgency = urgency
    self.dueDate = dueDate
    self.plantId = plantId
    self.description = description
    self.location = location
    self.conditions = conditions
  }
}

/// Response model for task creation
struct TaskResponse: Codable {
  let id: UUID
  let taskName: String
  let urgency: TaskType
  let dueDate: Date
  let plantId: UUID
  let description: String?
  let location: String
  let conditions: [String]?
  let status: TaskStatus
  let createdAt: Date
  let updatedAt: Date

  enum CodingKeys: String, CodingKey {
    case id
    case taskName = "task_name"
    case urgency
    case dueDate = "due_date"
    case plantId = "plant_id"
    case description
    case location
    case conditions
    case status
    case createdAt = "created_at"
    case updatedAt = "updated_at"
  }
}

/// Request model for updating an existing task
struct UpdateTaskRequest: Codable {
  let taskName: String?
  let urgency: TaskType?
  let dueDate: Date?
  let description: String?
  let conditions: [String]?
  let status: TaskStatus?

  enum CodingKeys: String, CodingKey {
    case taskName = "task_name"
    case urgency
    case dueDate = "due_date"
    case description
    case conditions
    case status
  }

  init(
    taskName: String? = nil,
    urgency: TaskType? = nil,
    dueDate: Date? = nil,
    description: String? = nil,
    conditions: [String]? = nil,
    status: TaskStatus? = nil
  ) {
    self.taskName = taskName
    self.urgency = urgency
    self.dueDate = dueDate
    self.description = description
    self.conditions = conditions
    self.status = status
  }
}

/// Response wrapper for task operations
typealias TaskAPIResponse = APIResponse<TaskResponse>
typealias TasksAPIResponse = APIResponse<[TaskResponse]>
