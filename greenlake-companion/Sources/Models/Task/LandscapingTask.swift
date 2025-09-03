import Foundation

struct LandscapingTask: Identifiable, Hashable {
  let id: UUID
  let title: String
  let description: String
  let taskType: TaskType
  let plantType: PlantType
  let status: TaskStatus
  let plantName: String
  let location: String
  let dueDate: Date
  let dateCreated: Date
  let dateModified: Date?
  let dateClosed: Date?

  init(
    id: UUID = UUID(),
    title: String,
    description: String,
    taskType: TaskType,
    plantType: PlantType,
    status: TaskStatus,
    plantName: String,
    location: String,
    dueDate: Date,
    dateCreated: Date,
    dateModified: Date?,
    dateClosed: Date?
  ) {
    self.id = id
    self.title = title
    self.description = description
    self.taskType = taskType
    self.plantType = plantType
    self.status = status
    self.plantName = plantName
    self.location = location
    self.dueDate = dueDate
    self.dateCreated = dateCreated
    self.dateModified = dateModified
    self.dateClosed = dateClosed
  }

  var imageName: String {
    switch plantType {
    case .tree: return "tree.fill"
    case .groundCover: return "camera.macro"
    case .bush: return "cloud.fill"
    }
  }

  var urgencyLabel: UrgencyLabel {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    let due = calendar.startOfDay(for: dueDate)
    let daysUntilDue = calendar.dateComponents([.day], from: today, to: due).day ?? 0
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

  var taskTimeline: [TaskChangelog] {
    generateTimeline()
  }

  private func generateTimeline() -> [TaskChangelog] {
    var changelogs: [TaskChangelog] = []
    let majorFlowPath: [TaskStatus] = [.diajukan, .aktif, .diperiksa]
    let minorFlowPath: [TaskStatus] = [.aktif]
    var historicalFlow: [TaskStatus] = []

    if taskType == .major {
      if status == .selesai || status == .terdenda || status == .dialihkan {
        historicalFlow = majorFlowPath + [status]
      } else if let currentIndex = majorFlowPath.firstIndex(of: status) {
        historicalFlow = Array(majorFlowPath.prefix(through: currentIndex))
      }
    } else {
      if status == .selesai || status == .terdenda {
        historicalFlow = minorFlowPath + [status]
      } else {
        historicalFlow = minorFlowPath
      }
    }

    guard !historicalFlow.isEmpty else { return [] }

    let startTime = dateCreated
    let endTime = dateModified ?? dateClosed ?? Date()
    let totalDuration = endTime.timeIntervalSince(startTime)
    let stepInterval = totalDuration / Double(historicalFlow.count)

    for (index, currentStatus) in historicalFlow.enumerated() {
      let statusBefore = index == 0 ? nil : historicalFlow[index - 1]
      let changeDate = startTime.addingTimeInterval(stepInterval * Double(index + 1))
      let newLog = TaskChangelog(
        userId: "Rizky",
        taskId: id.uuidString,
        date: changeDate,
        statusBefore: statusBefore,
        statusAfter: currentStatus,
        description: "Status diubah menjadi \(currentStatus.displayName)."
      )
      changelogs.append(newLog)
    }

    return changelogs
  }
}

let sampleTasks: [LandscapingTask] = [
  LandscapingTask(
    title: "Pemangkasan Berat Pohon Angsana di Jl. Darmo",
    description: "Fokus pada pemotongan dahan yang menjulur ke kabel listrik dan berpotensi patah saat angin kencang.",
    taskType: .major,
    plantType: .tree,
    status: .aktif,
    plantName: "Pinus Merkusi",
    location: "Blok A - 1",
    dueDate: Date(timeIntervalSince1970: 1751031933),
    dateCreated: Date(timeIntervalSince1970: 1750599933),
    dateModified: Date(timeIntervalSince1970: 1750945533),
    dateClosed: nil
  ),
  LandscapingTask(
    title: "Penanaman Massal Semak Lantana di Median Jalan",
    description: "Menanam 2000 bibit semak lantana untuk meningkatkan estetika dan menarik kupu-kupu.",
    taskType: .major,
    plantType: .bush,
    status: .selesai,
    plantName: "Semak Lantana",
    location: "Blok B - 5",
    dueDate: Date(timeIntervalSince1970: 1749800488),
    dateCreated: Date(timeIntervalSince1970: 1749454888),
    dateModified: Date(timeIntervalSince1970: 1749800488),
    dateClosed: Date(timeIntervalSince1970: 1750232488)
  ),
  LandscapingTask(
    title: "Pemotongan Rumput Hias Taman Depan Kantor",
    description: "Memotong rumput secara rutin menggunakan mesin potong untuk menjaga ketinggian ideal 3 cm.",
    taskType: .minor,
    plantType: .groundCover,
    status: .aktif,
    plantName: "Rumput Hias",
    location: "Blok C - 3",
    dueDate: Date(timeIntervalSince1970: 1751118061),
    dateCreated: Date(timeIntervalSince1970: 1750371661),
    dateModified: Date(timeIntervalSince1970: 1750803661),
    dateClosed: nil
  )
]
