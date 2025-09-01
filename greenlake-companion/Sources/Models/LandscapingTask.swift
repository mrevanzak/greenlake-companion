//
//  Task.swift
//  greenlake-companion
//
//  Created by Savio Enoson on 01/09/25.
//


import Foundation

struct LandscapingTask: Identifiable, Hashable {
  let id = UUID()
  var imageName: String {
    switch self.plantType {
    case .tree:
      return "tree.fill"
    case .groundCover:
      return "cloud.fill"
    case .bush:
      return "camera.macro"
    }
  }
  let title: String
  let description: String
  var location: String {  // TODO: Change to LET variable using database entry
    return generateRandomLocation()
  }
  var plantInstance: String {
    switch self.plantType {
    case .tree:
      return "Pinus Merkusi"
    case .groundCover:
      return "Rumput Manila"
    case .bush:
      return "Semak Keren"
    }
  }
  
  var urgencyLabel: UrgencyLabel {
    var daysUntilDue: Int {
        let calendar = Calendar.current
//        let today = calendar.startOfDay(for: Date()) // Current date at midnight
        let today = calendar.startOfDay(for: dateFormatter.date(from: "24-06-2025")!) // Debug, later use current time
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
  let status: TaskStatus
  
  let dueDate: Date
  let dateCreated: Date
  let dateModified: Date?
  let dateClosed: Date?
  
  init(title: String, description: String, taskType: TaskType, plantType: PlantType, status: TaskStatus, dueDate: Date, dateCreated: Date, dateModified: Date?, dateClosed: Date?) {
    self.title = title
    self.description = description
    self.taskType = taskType
    self.plantType = plantType
    self.status = status
    self.dueDate = dueDate
    self.dateCreated = dateCreated
    self.dateModified = dateModified
    self.dateClosed = dateClosed
  }
}

private func generateRandomLocation() -> String {
    let blocks = ["A", "B", "C", "D"]
    let unitNumber = Int.random(in: 1...30)
    
    // Safely unwrap the random element, defaulting to "A" if it somehow fails.
    let block = blocks.randomElement() ?? "A"
    
    return "Blok \(block) - \(unitNumber)"
}

let sampleTasks: [LandscapingTask] = [
    // MARK: - Major Tasks
    // Plant Type: Pohon
    LandscapingTask(title: "Major task for Pohon", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", taskType: .major, plantType: .tree, status: .aktif, dueDate: Date(timeIntervalSince1970: 1751031933), dateCreated: Date(timeIntervalSince1970: 1750599933), dateModified: Date(timeIntervalSince1970: 1750945533), dateClosed: nil),
    LandscapingTask(title: "Major task for Pohon", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", taskType: .major, plantType: .tree, status: .diajukan, dueDate: Date(timeIntervalSince1970: 1750869789), dateCreated: Date(timeIntervalSince1970: 1750005789), dateModified: Date(timeIntervalSince1970: 1750178589), dateClosed: nil),
    LandscapingTask(title: "Major task for Pohon", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", taskType: .major, plantType: .tree, status: .diperiksa, dueDate: Date(timeIntervalSince1970: 1749372198), dateCreated: Date(timeIntervalSince1970: 1749112998), dateModified: Date(timeIntervalSince1970: 1749372198), dateClosed: nil),
    LandscapingTask(title: "Major task for Pohon", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", taskType: .major, plantType: .tree, status: .selesai, dueDate: Date(timeIntervalSince1970: 1750232541), dateCreated: Date(timeIntervalSince1970: 1749502941), dateModified: Date(timeIntervalSince1970: 1749675741), dateClosed: Date(timeIntervalSince1970: 1750021341)),
    LandscapingTask(title: "Major task for Pohon", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", taskType: .major, plantType: .tree, status: .terdenda, dueDate: Date(timeIntervalSince1970: 1752003859), dateCreated: Date(timeIntervalSince1970: 1751139459), dateModified: Date(timeIntervalSince1970: 1751571459), dateClosed: Date(timeIntervalSince1970: 1751830659)),
    LandscapingTask(title: "Major task for Pohon", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", taskType: .major, plantType: .tree, status: .dialihkan, dueDate: Date(timeIntervalSince1970: 1750444539), dateCreated: Date(timeIntervalSince1970: 1750098939), dateModified: Date(timeIntervalSince1970: 1750530939), dateClosed: nil),
    // Plant Type: Semak
    LandscapingTask(title: "Major task for Semak", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", taskType: .major, plantType: .bush, status: .aktif, dueDate: Date(timeIntervalSince1970: 1750529149), dateCreated: Date(timeIntervalSince1970: 1749747949), dateModified: Date(timeIntervalSince1970: 1750093549), dateClosed: nil),
    LandscapingTask(title: "Major task for Semak", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", taskType: .major, plantType: .bush, status: .diajukan, dueDate: Date(timeIntervalSince1970: 1751293111), dateCreated: Date(timeIntervalSince1970: 1750861111), dateModified: Date(timeIntervalSince1970: 1751120311), dateClosed: nil),
    LandscapingTask(title: "Major task for Semak", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", taskType: .major, plantType: .bush, status: .diperiksa, dueDate: Date(timeIntervalSince1970: 1750298668), dateCreated: Date(timeIntervalSince1970: 1750125868), dateModified: Date(timeIntervalSince1970: 1750557868), dateClosed: nil),
    LandscapingTask(title: "Major task for Semak", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", taskType: .major, plantType: .bush, status: .selesai, dueDate: Date(timeIntervalSince1970: 1749800488), dateCreated: Date(timeIntervalSince1970: 1749454888), dateModified: Date(timeIntervalSince1970: 1749800488), dateClosed: Date(timeIntervalSince1970: 1750232488)),
    LandscapingTask(title: "Major task for Semak", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", taskType: .major, plantType: .bush, status: .terdenda, dueDate: Date(timeIntervalSince1970: 1751073050), dateCreated: Date(timeIntervalSince1970: 1750245050), dateModified: Date(timeIntervalSince1970: 1750677050), dateClosed: Date(timeIntervalSince1970: 1750936250)),
    LandscapingTask(title: "Major task for Semak", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", taskType: .major, plantType: .bush, status: .dialihkan, dueDate: Date(timeIntervalSince1970: 1750847008), dateCreated: Date(timeIntervalSince1970: 1749811408), dateModified: Date(timeIntervalSince1970: 1749984208), dateClosed: nil),
    // Plant Type: Ground Cover
    LandscapingTask(title: "Major task for Ground Cover", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", taskType: .major, plantType: .groundCover, status: .aktif, dueDate: Date(timeIntervalSince1970: 1750121988), dateCreated: Date(timeIntervalSince1970: 1750035588), dateModified: Date(timeIntervalSince1970: 1750381188), dateClosed: nil),
    LandscapingTask(title: "Major task for Ground Cover", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", taskType: .major, plantType: .groundCover, status: .diajukan, dueDate: Date(timeIntervalSince1970: 1749579803), dateCreated: Date(timeIntervalSince1970: 1749320603), dateModified: Date(timeIntervalSince1970: 1749752603), dateClosed: nil),
    LandscapingTask(title: "Major task for Ground Cover", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", taskType: .major, plantType: .groundCover, status: .diperiksa, dueDate: Date(timeIntervalSince1970: 1750446014), dateCreated: Date(timeIntervalSince1970: 1749666014), dateModified: Date(timeIntervalSince1970: 1749925214), dateClosed: nil),
    LandscapingTask(title: "Major task for Ground Cover", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", taskType: .major, plantType: .groundCover, status: .selesai, dueDate: Date(timeIntervalSince1970: 1751627893), dateCreated: Date(timeIntervalSince1970: 1750679893), dateModified: Date(timeIntervalSince1970: 1751111893), dateClosed: Date(timeIntervalSince1970: 1751457493)),
    LandscapingTask(title: "Major task for Ground Cover", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", taskType: .major, plantType: .groundCover, status: .terdenda, dueDate: Date(timeIntervalSince1970: 1750062984), dateCreated: Date(timeIntervalSince1970: 1749890184), dateModified: Date(timeIntervalSince1970: 1750062984), dateClosed: Date(timeIntervalSince1970: 1750408584)),
    LandscapingTask(title: "Major task for Ground Cover", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", taskType: .major, plantType: .groundCover, status: .dialihkan, dueDate: Date(timeIntervalSince1970: 1750844028), dateCreated: Date(timeIntervalSince1970: 1750240428), dateModified: Date(timeIntervalSince1970: 1750413228), dateClosed: nil),

    // MARK: - Minor Tasks
    // Plant Type: Pohon
    LandscapingTask(title: "Minor task for Pohon", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", taskType: .minor, plantType: .tree, status: .aktif, dueDate: Date(timeIntervalSince1970: 1750487288), dateCreated: Date(timeIntervalSince1970: 1750314488), dateModified: Date(timeIntervalSince1970: 1750746488), dateClosed: nil),
    LandscapingTask(title: "Minor task for Pohon", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", taskType: .minor, plantType: .tree, status: .diajukan, dueDate: Date(timeIntervalSince1970: 1750795935), dateCreated: Date(timeIntervalSince1970: 1750536735), dateModified: Date(timeIntervalSince1970: 1750623135), dateClosed: nil),
    LandscapingTask(title: "Minor task for Pohon", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", taskType: .minor, plantType: .tree, status: .diperiksa, dueDate: Date(timeIntervalSince1970: 1750172736), dateCreated: Date(timeIntervalSince1970: 1749567936), dateModified: Date(timeIntervalSince1970: 1749827136), dateClosed: nil),
    LandscapingTask(title: "Minor task for Pohon", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", taskType: .minor, plantType: .tree, status: .selesai, dueDate: Date(timeIntervalSince1970: 1751108517), dateCreated: Date(timeIntervalSince1970: 1750849317), dateModified: Date(timeIntervalSince1970: 1751022117), dateClosed: Date(timeIntervalSince1970: 1751367717)),
    LandscapingTask(title: "Minor task for Pohon", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", taskType: .minor, plantType: .tree, status: .terdenda, dueDate: Date(timeIntervalSince1970: 1750536299), dateCreated: Date(timeIntervalSince1970: 1749845899), dateModified: Date(timeIntervalSince1970: 1750191499), dateClosed: Date(timeIntervalSince1970: 1750364299)),
    LandscapingTask(title: "Minor task for Pohon", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", taskType: .minor, plantType: .tree, status: .dialihkan, dueDate: Date(timeIntervalSince1970: 1750766056), dateCreated: Date(timeIntervalSince1970: 1750247656), dateModified: Date(timeIntervalSince1970: 1750679656), dateClosed: nil),
    // Plant Type: Semak
    LandscapingTask(title: "Minor task for Semak", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", taskType: .minor, plantType: .bush, status: .aktif, dueDate: Date(timeIntervalSince1970: 1750889321), dateCreated: Date(timeIntervalSince1970: 1750199321), dateModified: Date(timeIntervalSince1970: 1750372121), dateClosed: nil),
    LandscapingTask(title: "Minor task for Semak", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", taskType: .minor, plantType: .bush, status: .diajukan, dueDate: Date(timeIntervalSince1970: 1750066820), dateCreated: Date(timeIntervalSince1970: 1749286820), dateModified: Date(timeIntervalSince1970: 1749718820), dateClosed: nil),
    LandscapingTask(title: "Minor task for Semak", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", taskType: .minor, plantType: .bush, status: .diperiksa, dueDate: Date(timeIntervalSince1970: 1751055528), dateCreated: Date(timeIntervalSince1970: 1750796328), dateModified: Date(timeIntervalSince1970: 1751228328), dateClosed: nil),
    LandscapingTask(title: "Minor task for Semak", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", taskType: .minor, plantType: .bush, status: .selesai, dueDate: Date(timeIntervalSince1970: 1750168441), dateCreated: Date(timeIntervalSince1970: 1749909241), dateModified: Date(timeIntervalSince1970: 1750168441), dateClosed: Date(timeIntervalSince1970: 1750514041)),
    LandscapingTask(title: "Minor task for Semak", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", taskType: .minor, plantType: .bush, status: .terdenda, dueDate: Date(timeIntervalSince1970: 1750791887), dateCreated: Date(timeIntervalSince1970: 1750007887), dateModified: Date(timeIntervalSince1970: 1750180687), dateClosed: Date(timeIntervalSince1970: 1750439887)),
    LandscapingTask(title: "Minor task for Semak", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", taskType: .minor, plantType: .bush, status: .dialihkan, dueDate: Date(timeIntervalSince1970: 1749480393), dateCreated: Date(timeIntervalSince1970: 1749221193), dateModified: Date(timeIntervalSince1970: 1749393993), dateClosed: nil),
    // Plant Type: Ground Cover
    LandscapingTask(title: "Minor task for Ground Cover", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", taskType: .minor, plantType: .groundCover, status: .aktif, dueDate: Date(timeIntervalSince1970: 1751118061), dateCreated: Date(timeIntervalSince1970: 1750371661), dateModified: Date(timeIntervalSince1970: 1750803661), dateClosed: nil),
    LandscapingTask(title: "Minor task for Ground Cover", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", taskType: .minor, plantType: .groundCover, status: .diajukan, dueDate: Date(timeIntervalSince1970: 1751283846), dateCreated: Date(timeIntervalSince1970: 1751111046), dateModified: Date(timeIntervalSince1970: 1751456646), dateClosed: nil),
    LandscapingTask(title: "Minor task for Ground Cover", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", taskType: .minor, plantType: .groundCover, status: .diperiksa, dueDate: Date(timeIntervalSince1970: 1749480407), dateCreated: Date(timeIntervalSince1970: 1749138407), dateModified: Date(timeIntervalSince1970: 1749224807), dateClosed: nil),
    LandscapingTask(title: "Minor task for Ground Cover", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", taskType: .minor, plantType: .groundCover, status: .selesai, dueDate: Date(timeIntervalSince1970: 1751197782), dateCreated: Date(timeIntervalSince1970: 1750592982), dateModified: Date(timeIntervalSince1970: 1750938582), dateClosed: Date(timeIntervalSince1970: 1751370582)),
    LandscapingTask(title: "Minor task for Ground Cover", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", taskType: .minor, plantType: .groundCover, status: .terdenda, dueDate: Date(timeIntervalSince1970: 1750369306), dateCreated: Date(timeIntervalSince1970: 1749764506), dateModified: Date(timeIntervalSince1970: 1750023706), dateClosed: Date(timeIntervalSince1970: 1750369306)),
    LandscapingTask(title: "Minor task for Ground Cover", description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.", taskType: .minor, plantType: .groundCover, status: .dialihkan, dueDate: Date(timeIntervalSince1970: 1750258705), dateCreated: Date(timeIntervalSince1970: 1749479905), dateModified: Date(timeIntervalSince1970: 1749911905), dateClosed: nil)
]
