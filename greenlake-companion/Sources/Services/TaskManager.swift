import Foundation

@MainActor
final class TaskManager: ObservableObject {
  static let shared = TaskManager()

  @Published var tasks: [LandscapingTask] = []
  @Published var selectedTask: LandscapingTask?
  @Published var isLoading = false
  @Published var error: TaskError?

  private let service: TaskServiceProtocol

  init(service: TaskServiceProtocol = TaskService()) {
    self.service = service
  }

  func loadTasks() async {
    isLoading = true
    defer { isLoading = false }
    do {
      tasks = try await service.fetchTasks()
    } catch {
      self.error = .loadFailed(error)
    }
  }

  func createTask(_ task: LandscapingTask) async {
    isLoading = true
    defer { isLoading = false }
    do {
      let created = try await service.createTask(task)
      tasks.insert(created, at: 0)
    } catch {
      self.error = .createFailed(error)
    }
  }

  func updateTask(_ task: LandscapingTask) async {
    isLoading = true
    defer { isLoading = false }
    do {
      let updated = try await service.updateTask(task)
      if let index = tasks.firstIndex(where: { $0.id == updated.id }) {
        tasks[index] = updated
      }
    } catch {
      self.error = .updateFailed(error)
    }
  }

  func deleteTask(id: UUID) async {
    isLoading = true
    defer { isLoading = false }
    do {
      try await service.deleteTask(id: id)
      tasks.removeAll { $0.id == id }
    } catch {
      self.error = .deleteFailed(error)
    }
  }
}
