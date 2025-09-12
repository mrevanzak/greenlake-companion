//
//  AgendaViewModel.swift
//  greenlake-companion
//
//  Created by AI Assistant on 05/01/25.
//

import Combine
import Foundation
import SwiftUI

@MainActor
class AgendaViewModel: ObservableObject {
  static let shared = AgendaViewModel()
  // MARK: - Published Properties
  
  @Published var tasks: [LandscapingTask] = []
  @Published var timeline: [TaskChangelog] = []
  @Published var filteredTasks: [LandscapingTask] = []
  @Published var selectedTask: LandscapingTask?
  @Published var searchText: String = ""
  @Published var isLoading = false
  @Published var errorMessage: String?
  
  @Published var requestedExportType: PDFReportType?
  @Published var tasksToExport: [LandscapingTask]?
  
  // MARK: - Private Properties
  
  private let taskService: TaskServiceProtocol
  private var cancellables = Set<AnyCancellable>()
  
  // MARK: - Public Properties
  
  let filterViewModel: FilterViewModel
  
  // MARK: - Initialization
  
  init(
    taskService: TaskServiceProtocol = TaskService(),
    filterViewModel: FilterViewModel = FilterViewModel()
  ) {
    self.taskService = taskService
    self.filterViewModel = filterViewModel
    
    setupReactiveUpdates()
  }
  
  // MARK: - Public Methods
  
  /// Load tasks from the API asynchronously
  func loadTasks() async {
    isLoading = true
    errorMessage = nil
    
    do {
      let fetchedTasks = try await taskService.fetchTasks()
      tasks = fetchedTasks
      applyFilters()
      selectFirstTaskIfNeeded()
    } catch {
      errorMessage = error.localizedDescription
      print("❌ Error loading tasks: \(error)")
      print(error.localizedDescription)
    }
    isLoading = false
  }
  
  /// Select a specific task
  func selectTask(_ task: LandscapingTask) {
    selectedTask = task
  }
  
  /// Select the first task if none is selected
  func selectFirstTaskIfNeeded() {
    if selectedTask == nil && !filteredTasks.isEmpty {
      selectedTask = filteredTasks.first
    }
  }
  
  // MARK: - Private Methods
  
  /// Set up reactive updates for filter changes
  private func setupReactiveUpdates() {
    // Combine all filter properties and search text for reactive updates
    Publishers.CombineLatest4(
      filterViewModel.$taskType,
      filterViewModel.$urgency,
      filterViewModel.$plantType,
      filterViewModel.$status
    )
    .combineLatest(
      Publishers.CombineLatest3(
        filterViewModel.$startDate,
        filterViewModel.$endDate,
        filterViewModel.$sortKey
      )
    )
    .combineLatest(
      Publishers.CombineLatest(
        filterViewModel.$sortOrder,
        $searchText
      )
    )
    .sink { [weak self] _ in
        DispatchQueue.main.async {
            self?.applyFilters()
        }
    }
    .store(in: &cancellables)
  }
  
  /// Apply all filters and sorting to the tasks
  private func applyFilters() {
      print("🚦 Applying filters...")
      print("🔢 Total tasks before filtering: \(tasks.count)")
      print("📦 All task types:")
      tasks.forEach { print("  - \(String(describing: $0.title)) → \($0.taskType)") }
      print("✅ Filtering with selected task types: \(filterViewModel.taskType)")

      var processedTasks = tasks

      print("🎛️ Current filters:")
      print("  - TaskType: \(filterViewModel.taskType)")
      print("  - Urgency: \(filterViewModel.urgency)")
      print("  - PlantType: \(filterViewModel.plantType)")
      print("  - Status: \(filterViewModel.status)")
      print("  - SearchText: '\(searchText)'")
      print("  - DateRange: \(filterViewModel.startDate) to \(filterViewModel.endDate)")
      print("  - SortKey: \(filterViewModel.sortKey)")
      print("  - SortOrder: \(filterViewModel.sortOrder)")

    processedTasks = processedTasks.filter { task in
      let typeMatch = filterViewModel.taskType.isEmpty || filterViewModel.taskType.contains(task.taskType)
      let urgencyMatch = filterViewModel.urgency.isEmpty || filterViewModel.urgency.contains(task.urgencyLabel)
      let plantMatch = filterViewModel.plantType.isEmpty || filterViewModel.plantType.contains(task.plantType)
      let statusMatch = filterViewModel.status.isEmpty || filterViewModel.status.contains(task.status)
      
      if !typeMatch {
          print("❌ Task '\(task.title)' filtered out by taskType: \(task.taskType)")
      }
      
      return typeMatch && urgencyMatch && plantMatch && statusMatch
    }
    print("✅ After enum filters: \(processedTasks.count) tasks")
    
    let isDefaultDateRange = Calendar.current.isDate(filterViewModel.startDate, inSameDayAs: filterViewModel.endDate)
    
    if filterViewModel.startDate <= filterViewModel.endDate && !isDefaultDateRange {
      let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: filterViewModel.endDate)) ?? filterViewModel.endDate
      let startOfDay = Calendar.current.startOfDay(for: filterViewModel.startDate)
      
      processedTasks = processedTasks.filter { task in
        return task.dateCreated >= startOfDay && task.dateCreated < endOfDay
      }
      
      print("📅 After date range filter: \(processedTasks.count) tasks")
    } else {
      print("📅 Date range filter skipped (default or invalid)")
    }
    
    if !searchText.isEmpty {
      processedTasks = processedTasks.filter { task in
        task.title.localizedCaseInsensitiveContains(searchText) || task.description.localizedCaseInsensitiveContains(searchText)
      }
      print("🔍 After search text filter: \(processedTasks.count) tasks")
    }
    
    print("🔃 Applying sorting by \(filterViewModel.sortKey) in \(filterViewModel.sortOrder) order")
    
    switch filterViewModel.sortKey {
    case .dateCreated:
      processedTasks.sort {
        filterViewModel.sortOrder == .ascending ? $0.dateCreated < $1.dateCreated : $0.dateCreated > $1.dateCreated
      }
      
    case .dateModified, .dateClosed:
      processedTasks.sort { lhs, rhs in
        let lhsDate = filterViewModel.sortKey == .dateModified ? lhs.dateModified : lhs.dateClosed
        let rhsDate = filterViewModel.sortKey == .dateModified ? rhs.dateModified : rhs.dateClosed
        let isAscending = filterViewModel.sortOrder == .ascending
        
        switch (lhsDate, rhsDate) {
        case let (l?, r?): return isAscending ? l < r : l > r
        case (_?, nil): return true
        case (nil, _?): return false
        case (nil, nil): return false
        }
      }
    }
    
    filteredTasks = processedTasks
    print("🎯 Final filtered task count: \(filteredTasks.count)")
    if let sample = filteredTasks.first {
      print("📌 Sample task: \(sample.title) - \(sample.status) - \(sample.urgencyLabel)")
    }
    
    if let selected = selectedTask, !filteredTasks.contains(selected) {
      selectedTask = filteredTasks.first
    }
  }
  
  func getHeader() -> [LandscapingTask] {
    return Array(tasks.prefix(10))
  }
}
