//
//  ActiveTasksViewModel.swift
//  greenlake-companion
//
//  Created by AI Assistant on 09/10/25.
//

import Foundation

final class ActiveTasksViewModel: ObservableObject {
  @Published var activeTasks: [LandscapingTask] = []
  @Published var isLoading = false
  @Published var errorMessage: String?

  private let taskService: TaskServiceProtocol

  init(taskService: TaskServiceProtocol = TaskService()) {
    self.taskService = taskService
  }

  @MainActor
  func load() async {
    isLoading = true
    errorMessage = nil
    defer { isLoading = false }
    do {
      let tasks = try await taskService.fetchTasks()
      activeTasks =
        tasks
        .filter { $0.status == .aktif }
        .sorted { $0.dateCreated > $1.dateCreated }
    } catch {
      errorMessage = error.localizedDescription
    }
  }
}
