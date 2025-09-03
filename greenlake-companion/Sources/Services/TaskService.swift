//
//  TaskService.swift
//  greenlake-companion
//
//  Created by AI Assistant on 05/01/25.
//

import Foundation

/// Protocol defining task service operations for easy testing and API integration
protocol TaskServiceProtocol {
  /// Create a new task with optional image attachments
  /// - Parameters:
  ///   - request: The task creation request
  ///   - images: Optional array of image data to upload
  /// - Returns: The created task response
  func createTask(_ request: CreateTaskRequest, with images: [Data]) async throws -> TaskResponse

  /// Fetch all tasks
  /// - Returns: Array of task responses
  func fetchTasks() async throws -> [TaskResponse]

  /// Fetch a specific task by ID
  /// - Parameter id: The task ID
  /// - Returns: The task response
  func fetchTask(id: UUID) async throws -> TaskResponse

  /// Update an existing task
  /// - Parameters:
  ///   - id: The task ID
  ///   - request: The update request
  /// - Returns: The updated task response
  func updateTask(id: UUID, with request: UpdateTaskRequest) async throws -> TaskResponse

  /// Delete a task
  /// - Parameter id: The task ID
  func deleteTask(id: UUID) async throws
}

/// Task service implementation using the network manager
class TaskService: TaskServiceProtocol {
  // MARK: - Properties

  private let networkManager: NetworkManagerProtocol

  // MARK: - Initialization

  init(networkManager: NetworkManagerProtocol = NetworkManager()) {
    self.networkManager = networkManager
  }

  // MARK: - TaskServiceProtocol Implementation

  func createTask(_ request: CreateTaskRequest, with images: [Data]) async throws -> TaskResponse {
    return try await LoadingIndicator.withLoading(
      title: "Creating Task...",
      subtitle: images.isEmpty ? "Saving task to server" : "Uploading task with images"
    ) {
      do {
        print("📋 Creating task in API...")

        // If we have images, use multipart upload, otherwise use regular JSON
        if !images.isEmpty {
          let response: TaskAPIResponse = try await networkManager.uploadMultipart(
            TaskEndpoint.createTask,
            with: request,
            files: images,
            fileFieldName: "files"
          )
          print("✅ Successfully created task with images in API")
          return response.data
        } else {
          let response: TaskAPIResponse = try await networkManager.request(
            TaskEndpoint.createTask, with: request)
          print("✅ Successfully created task in API")
          return response.data
        }
      } catch {
        print("❌ Error creating task in API: \(error)")
        throw error
      }
    }
  }

  func fetchTasks() async throws -> [TaskResponse] {
    return try await LoadingIndicator.withLoading(
      title: "Loading Tasks...",
      subtitle: "Fetching task data from server"
    ) {
      do {
        print("📋 Fetching tasks from API...")
        let response: TasksAPIResponse = try await networkManager.request(TaskEndpoint.fetchTasks)
        print("✅ Successfully decoded \(response.data.count) tasks from API")
        return response.data
      } catch {
        print("❌ Error fetching tasks from API: \(error)")
        throw error
      }
    }
  }

  func fetchTask(id: UUID) async throws -> TaskResponse {
    return try await LoadingIndicator.withLoading(
      title: "Loading Task...",
      subtitle: "Fetching task details from server"
    ) {
      do {
        print("📋 Fetching task \(id) from API...")
        let response: TaskAPIResponse = try await networkManager.request(
          TaskEndpoint.fetchTask(id: id))
        print("✅ Successfully fetched task from API")
        return response.data
      } catch {
        print("❌ Error fetching task from API: \(error)")
        throw error
      }
    }
  }

  func updateTask(id: UUID, with request: UpdateTaskRequest) async throws -> TaskResponse {
    return try await LoadingIndicator.withLoading(
      title: "Updating Task...",
      subtitle: "Saving changes to task information"
    ) {
      do {
        print("📋 Updating task \(id) in API...")
        let response: TaskAPIResponse = try await networkManager.request(
          TaskEndpoint.updateTask(id: id), with: request)
        print("✅ Successfully updated task in API")
        return response.data
      } catch {
        print("❌ Error updating task in API: \(error)")
        throw error
      }
    }
  }

  func deleteTask(id: UUID) async throws {
    try await LoadingIndicator.withLoading(
      title: "Deleting Task...",
      subtitle: "Removing task from the system"
    ) {
      do {
        print("📋 Deleting task \(id) from API...")
        let _: MessageOnlyResponse = try await networkManager.request(
          TaskEndpoint.deleteTask(id: id))
        print("✅ Successfully deleted task from API")
      } catch {
        print("❌ Error deleting task from API: \(error)")
        throw error
      }
    }
  }
}
