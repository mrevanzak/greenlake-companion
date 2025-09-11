//
//  Task.swift
//  greenlake-companion
//
//  Created by Savio Enoson on 01/09/25.
//

import Foundation

struct LandscapingTask: Identifiable, Hashable {
  let id : UUID
  var imageName: String {
    switch self.plantType {
    case .tree:
      return "tree.fill"
    case .groundCover:
      return "camera.macro"
    case .bush:
      return "cloud.fill"
    }
  }
  var title: String
  let description: String
  let location: String
  var size: Double {
    return Double.random(in: 1...100)
  }
  let area: Double
  let unit: String
  
  var urgencyLabel: UrgencyLabel {
    var daysUntilDue: Int {
      let calendar = Calendar.current
      let today = calendar.startOfDay(for: Date()) // Current date at midnight
      let due = calendar.startOfDay(for: dueDate)  // Due date at midnight
      
      // Calculate the difference in days.
      let components = calendar.dateComponents([.day], from: today, to: due)
      
      return components.day ?? 0
    }
    if daysUntilDue < 0 {
      return .overdue
    } else if daysUntilDue <= 3 {
      return .short
    } else if daysUntilDue <= 7 {
      return .normal
    } else {
      return .long
    }
  }
  
  let taskType: TaskType
  let plantType: PlantType
  let plant_name: String
  let status: TaskStatus
  let dueDate: Date
  let dateCreated: Date
  let dateModified: Date?
  let dateClosed: Date?
  
  init(id: UUID, title: String, location: String, description: String, area: Double, unit: String, taskType: TaskType, plantType: PlantType, plant_name: String, status: TaskStatus, dueDate: Date, dateCreated: Date, dateModified: Date?, dateClosed: Date?) {
    self.id = id
    self.title = title
    self.location = location
    self.description = description
    self.area = area
    self.unit = unit
    self.taskType = taskType
    self.plantType = plantType
    self.plant_name = plant_name
    self.status = status
    self.dueDate = dueDate
    self.dateCreated = dateCreated
    self.dateModified = dateModified
    self.dateClosed = dateClosed
  }
}

//let sampleTasks: [LandscapingTask] = [
//  LandscapingTask(id: UUID(), title: "Pemangkasan Berat Pohon Angsana di Jl. Darmo", location: "Blok A5", description: "Fokus pada pemotongan dahan yang menjulur ke kabel listrik dan berpotensi patah saat angin kencang.", area: 10, unit: "m2", taskType: .major, plantType: .tree, plant_name: "Pinus Ganteng", status: .aktif, dueDate: Date(timeIntervalSince1970: 1751031933), dateCreated: Date(timeIntervalSince1970: 1750599933), dateModified: Date(timeIntervalSince1970: 1750945533), dateClosed: nil)
//]
