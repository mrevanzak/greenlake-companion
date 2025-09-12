//
//  ActiveTasksViewModel.swift
//  greenlake-companion
//
//  Created by AI Assistant on 09/10/25.
//
import Foundation

@MainActor
class ActiveTasksViewModel: ObservableObject {
  @Published var isLoading = false
  @Published var errorMessage: String?
  @Published var activeTasks: [LandscapingTask] = []
  @Published var taskSummary: ActiveTasksData? = nil

  private let taskService: TaskServiceProtocol

  init(taskService: TaskServiceProtocol = TaskService()) {
    self.taskService = taskService
  }

  func load() async {
    isLoading = true
    errorMessage = nil
    defer { isLoading = false }

    do {
      async let summary = taskService.fetchActiveTasks()
      async let aktifTasks = taskService.fetchTasks(status: .aktif)
      let (taskSummary, activeTasks) = try await (summary, aktifTasks)
      self.taskSummary = taskSummary
      self.activeTasks = activeTasks
    } catch {
      print("❌ Failed to load active tasks: \(error)")
      self.errorMessage = "Gagal memuat data."
    }
  }
}
