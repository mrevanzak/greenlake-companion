//
//  TaskService.swift
//  greenlake-companion
//
//  Created by AI Assistant on 05/01/25.
//

import Foundation
import SwiftUI

/// Protocol defining task service operations for easy testing and API integration
protocol TaskServiceProtocol {
  /// Create a new task with optional image attachments
  /// - Parameters:
  ///   - request: The task creation request
  ///   - images: Optional array of image data to upload
  /// - Returns: The created task response
  func createTask(_ request: CreateTaskRequest, with images: [Data]) async throws
  -> CreateTaskResponse
  
  /// Fetch all tasks
  /// - Returns: Array of landscaping tasks
  func fetchTasks() async throws -> [LandscapingTask]
  
  /// Fetch a specific task by ID
  /// - Parameter id: The task ID
  /// - Returns: The task response
  func fetchTask(id: UUID) async throws -> TaskResponse
  
  func fetchTimeline(id: UUID) async throws -> [TaskChangelog]
  
  /// Update an existing task
  /// - Parameters:
  ///   - id: The task ID
  ///   - request: The update request
  /// - Returns: The updated task response
  func updateTask(id: UUID, with request: UpdateTaskRequest) async throws -> TaskResponse
  
  func updateTaskStatus(id: UUID, status: String, note: String?, photos: [Data]) async throws -> TaskResponse
  
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
  
  func createTask(_ request: CreateTaskRequest, with images: [Data]) async throws
  -> CreateTaskResponse
  {
    do {
      print("📋 Creating task in API...")
      
      // If we have images, use multipart upload, otherwise use regular JSON
      if !images.isEmpty {
        let response: APIResponse<CreateTaskResponse> = try await networkManager.uploadMultipart(
          TaskEndpoint.createTask,
          with: request,
          files: images,
          fileFieldName: "photos"
        )
        print("✅ Successfully created task with images in API")
        return response.data
      } else {
        let response: APIResponse<CreateTaskResponse> = try await networkManager.request(
          TaskEndpoint.createTask, with: request)
        print("✅ Successfully created task in API")
        return response.data
      }
    } catch {
      print("❌ Error creating task in API: \(error)")
      throw error
    }
  }
  
  func fetchTasks() async throws -> [LandscapingTask] {
    do {
      print("📋 Fetching tasks from API...")
      let response: TasksAPIResponse = try await networkManager.request(TaskEndpoint.fetchTasks)
      print("✅ Successfully decoded \(response.data.count) tasks from API")
      
      // Convert TaskResponse to LandscapingTask using the adapter
      let landscapingTasks = response.data.map { $0.toLandscapingTask() }
      print("✅ Successfully converted \(landscapingTasks.count) tasks to LandscapingTask format")
      return landscapingTasks
    } catch {
      print("❌ Error fetching tasks from API: \(error)")
      throw error
    }
  }
  
  func fetchTask(id: UUID) async throws -> TaskResponse {
    do {
      let response: TaskAPIResponse = try await networkManager.request(
        TaskEndpoint.fetchTask(id: id))
      print("✅ Successfully fetched task from API")
      return response.data
    } catch {
      print("❌ Error fetching task from API: \(error)")
      
      if let decodingError = error as? DecodingError {
        switch decodingError {
        case .typeMismatch(let type, let context):
          print("Type mismatch for type \(type), codingPath: \(context.codingPath), debugDescription: \(context.debugDescription)")
        case .keyNotFound(let key, let context):
          print("Key '\(key)' not found, codingPath: \(context.codingPath), debugDescription: \(context.debugDescription)")
        case .valueNotFound(let value, let context):
          print("Value '\(value)' not found, codingPath: \(context.codingPath), debugDescription: \(context.debugDescription)")
        case .dataCorrupted(let context):
          print("Data corrupted, codingPath: \(context.codingPath), debugDescription: \(context.debugDescription)")
        @unknown default:
          print("Unknown decoding error")
        }
      }
      
      throw error
    }
  }
  
  func fetchTimeline(id: UUID) async throws -> [TaskChangelog] {
      do {
          print("Fetching Task Timeline from API...")
          
          // Decode the correct shape
          let response: APIResponse<TimelineWrapper> = try await networkManager.request(
              TaskEndpoint.fetchTimeline(id: id)
          )
          
          print("✅ Successfully decoded timeline from API")
          return response.data.timeline
      } catch {
          print("❌ Error decoding timeline response: \(error)")
          if let decodingError = error as? DecodingError {
              print("🔍 Decoding error details: \(decodingError)")
          }
          throw error
      }
  }

  func updateTask(id: UUID, with request: UpdateTaskRequest) async throws -> TaskResponse {
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
  
  func updateTaskStatus(id: UUID, status: String, note: String?, photos: [Data]) async throws -> TaskResponse {
    do {
      let body = UpdateStatusRequest(status: status, note: note)
      let resp: UpdateStatusAPIResponse = try await networkManager.uploadMultipart(
        TaskEndpoint.updateStatus(id: id),
        with: body,
        files: photos,
        fileFieldName: "photos"
      )
      return resp.data
    } catch {
      print("❌ updateTaskStatus error: \(error)")
      throw error
    }
  }
  
  func deleteTask(id: UUID) async throws {
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
  
  func fetchImages(for tasks: [LandscapingTask]) async throws -> [UUID: [UIImage]] {
    return try await withThrowingTaskGroup(of: (UUID, [UIImage]).self) { group in
      var results: [UUID: [UIImage]] = [:]
      
      for task in tasks {
        group.addTask {
          let timeline = try await self.fetchTimeline(id: task.id)
          var downloadedImages: [UIImage] = []
          
          if let photos = timeline.last?.photos {
            for photo in photos {
              if let image = try? await self._fetchImage(from: photo.imageUrl) {
                downloadedImages.append(image)
              }
            }
          }
          
          return (task.id, downloadedImages)
        }
      }
      
      for try await (taskId, images) in group {
        results[taskId] = images
      }
      
      return results
    }
  }
  
  private func _fetchImage(from urlString: String) async throws -> UIImage {
    guard let url = URL(string: urlString) else {
      throw PDFGenerationError.invalidImageData
    }
    
    do {
      let (data, _) = try await URLSession.shared.data(from: url)
      if let image = UIImage(data: data) {
        return image
      } else {
        throw PDFGenerationError.invalidImageData
      }
    } catch {
      throw PDFGenerationError.networkError(error)
    }
  }
}
