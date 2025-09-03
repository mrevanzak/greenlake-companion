import Foundation

protocol TaskServiceProtocol {
  func fetchTasks() async throws -> [LandscapingTask]
  func createTask(_ task: LandscapingTask) async throws -> LandscapingTask
  func updateTask(_ task: LandscapingTask) async throws -> LandscapingTask
  func deleteTask(id: UUID) async throws
}

final class TaskService: TaskServiceProtocol {
  private let networkManager: NetworkManager

  init(networkManager: NetworkManager = NetworkManager()) {
    self.networkManager = networkManager
  }

  // TODO: Wire to API using NetworkManager when endpoints are ready.
  // GET /tasks -> fetchTasks()
  // POST /tasks -> createTask(_:)
  // PUT /tasks/{id} -> updateTask(_:)
  // DELETE /tasks/{id} -> deleteTask(id:)

  func fetchTasks() async throws -> [LandscapingTask] {
    return sampleTasks
  }

  func createTask(_ task: LandscapingTask) async throws -> LandscapingTask {
    return task
  }

  func updateTask(_ task: LandscapingTask) async throws -> LandscapingTask {
    return task
  }

  func deleteTask(id: UUID) async throws {
  }
}
