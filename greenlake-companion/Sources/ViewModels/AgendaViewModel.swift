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
  // MARK: - Published Properties

  @Published var tasks: [LandscapingTask] = []
  @Published var filteredTasks: [LandscapingTask] = []
  @Published var selectedTask: LandscapingTask?
  @Published var searchText: String = ""
  @Published var isLoading = false
  @Published var errorMessage: String?

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
      self?.applyFilters()
    }
    .store(in: &cancellables)
  }

  /// Apply all filters and sorting to the tasks
  private func applyFilters() {
    // 1. Start with the full list of tasks from API
    var processedTasks = tasks

    // 2. Apply all enum-based filters from the ViewModel
    processedTasks = processedTasks.filter { task in
      let typeMatch =
        filterViewModel.taskType.isEmpty || filterViewModel.taskType.contains(task.taskType)
      let urgencyMatch =
        filterViewModel.urgency.isEmpty || filterViewModel.urgency.contains(task.urgencyLabel)
      let plantMatch =
        filterViewModel.plantType.isEmpty || filterViewModel.plantType.contains(task.plantType)
      let statusMatch =
        filterViewModel.status.isEmpty || filterViewModel.status.contains(task.status)

      return typeMatch && urgencyMatch && plantMatch && statusMatch
    }

    // 3. Apply the date range filter if the date range is valid AND not the default
    let isDefaultDateRange = Calendar.current.isDate(
      filterViewModel.startDate, inSameDayAs: filterViewModel.endDate)

    if filterViewModel.startDate <= filterViewModel.endDate && !isDefaultDateRange {
      // To include the entire end date, we calculate the start of the *next* day
      let endOfDay =
        Calendar.current.date(
          byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: filterViewModel.endDate))
        ?? filterViewModel.endDate
      let startOfDay = Calendar.current.startOfDay(for: filterViewModel.startDate)

      processedTasks = processedTasks.filter { task in
        return task.dateCreated >= startOfDay && task.dateCreated < endOfDay
      }
    }

    // 4. Apply the search text filter to the already-filtered list
    if !searchText.isEmpty {
      processedTasks = processedTasks.filter { task in
        task.title.localizedCaseInsensitiveContains(searchText)
          || task.description.localizedCaseInsensitiveContains(searchText)
      }
    }

    // 5. Apply sorting as the final step
    switch filterViewModel.sortKey {
    case .dateCreated:
      processedTasks.sort {
        if filterViewModel.sortOrder == .ascending {
          return $0.dateCreated < $1.dateCreated
        } else {
          return $0.dateCreated > $1.dateCreated
        }
      }

    case .dateModified, .dateClosed:
      processedTasks.sort { lhs, rhs in
        // Determine which optional date property to use based on the sort key
        let lhsDate = (filterViewModel.sortKey == .dateModified) ? lhs.dateModified : lhs.dateClosed
        let rhsDate = (filterViewModel.sortKey == .dateModified) ? rhs.dateModified : rhs.dateClosed

        let isAscending = filterViewModel.sortOrder == .ascending

        switch (lhsDate, rhsDate) {
        // Case 1: Both tasks have a valid date. Compare them normally.
        case let (l?, r?):
          return isAscending ? l < r : l > r

        // Case 2: Only the left task has a date, so it comes first.
        case (_?, nil):
          return true

        // Case 3: Only the right task has a date, so it comes first.
        case (nil, _?):
          return false

        // Case 4: Both are nil, so their order doesn't matter.
        case (nil, nil):
          return false
        }
      }
    }

    // 6. Update the filtered tasks
    filteredTasks = processedTasks

    // 7. Update selected task if it's no longer in filtered results
    if let selected = selectedTask, !filteredTasks.contains(selected) {
      selectedTask = filteredTasks.first
    }
  }
}
