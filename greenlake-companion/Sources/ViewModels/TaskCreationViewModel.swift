import CoreLocation
import Foundation
import SwiftUI

@MainActor
final class TaskCreationViewModel: ObservableObject {
  @Published var title = ""
  @Published var description = ""
  @Published var taskType: TaskType = .minor
  @Published var status: TaskStatus = .diajukan
  @Published var dueDate: Date = Calendar.current.date(byAdding: .day, value: 7, to: Date())!

  private let plantManager: PlantManager
  private let taskManager: TaskManager

  init(plantManager: PlantManager = .shared, taskManager: TaskManager = .shared) {
    self.plantManager = plantManager
    self.taskManager = taskManager
  }

  var isValid: Bool {
    !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && plantManager.selectedPlant != nil
  }

  func create() async {
    guard let plant = plantManager.selectedPlant else { return }
    let task = LandscapingTask(
      title: title,
      description: description,
      taskType: taskType,
      plantType: plant.type,
      status: status,
      plantName: plant.name.isEmpty ? "Tanaman" : plant.name,
      location: Self.formatLocation(plant.location),
      dueDate: dueDate,
      dateCreated: Date(),
      dateModified: nil,
      dateClosed: nil
    )
    await taskManager.createTask(task)
  }

  private static func formatLocation(_ coord: CLLocationCoordinate2D) -> String {
    String(format: "Lat %.5f, Lon %.5f", coord.latitude, coord.longitude)
  }
}
