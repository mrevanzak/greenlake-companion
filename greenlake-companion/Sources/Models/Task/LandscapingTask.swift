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
  
let sampleTasks: [LandscapingTask] = [
//   MARK: - Major Tasks
//  Plant Type: Pohon
  LandscapingTask(id: UUID(), title: "Pemangkasan Berat Pohon Angsana di Jl. Darmo", location: "Blok A5", description: "Fokus pada pemotongan dahan yang menjulur ke kabel listrik dan berpotensi patah saat angin kencang.", area: 10, unit: "m2", taskType: .major, plantType: .tree, plant_name: "Pinus Ganteng", status: .aktif, dueDate: Date(timeIntervalSince1970: 1751031933), dateCreated: Date(timeIntervalSince1970: 1750599933), dateModified: Date(timeIntervalSince1970: 1750945533), dateClosed: nil)
]
//}
  
//  private func generateTimeline() -> [TaskChangelog] {
//    var changelogs: [TaskChangelog] = []
//
//    // 1. Define the complete potential status flows for each task type.
//    let majorFlowPath: [TaskStatus] = [.diajukan, .aktif, .diperiksa]
//    let minorFlowPath: [TaskStatus] = [.aktif]
//
//    var historicalFlow: [TaskStatus] = []
//
//    // 2. Determine the actual historical flow for this specific task
//    //    based on its type and current status.
//    if self.taskType == .major {
//      // If the task is in a final state, its history includes the full path.
//      if status == .selesai || status == .terdenda || status == .dialihkan {
//        historicalFlow = majorFlowPath + [status]
//      } else if let currentIndex = majorFlowPath.firstIndex(of: status) {
//        // Otherwise, its history is the path up to its current status.
//        historicalFlow = Array(majorFlowPath.prefix(through: currentIndex))
//      }
//    } else { // Minor Task
//      if status == .selesai || status == .terdenda {
//        historicalFlow = minorFlowPath + [status]
//      } else { // .aktif
//        historicalFlow = minorFlowPath
//      }
//    }
//
//    guard !historicalFlow.isEmpty else { return [] }
//
//    // 3. Create realistic dates for each changelog entry by distributing
//    //    them evenly between the creation and modification dates.
//    let startTime = self.dateCreated
//    let endTime = self.dateModified ?? self.dateClosed ?? Date() // Fallback to now if not modified/closed
//    let totalDuration = endTime.timeIntervalSince(startTime)
//    let stepInterval = totalDuration / Double(historicalFlow.count)
//
//    // 4. Create a changelog for each step in the determined historical flow.
//    for (index, currentStatus) in historicalFlow.enumerated() {
//      let statusBefore = index == 0 ? nil : historicalFlow[index - 1]
//      let changeDate = startTime.addingTimeInterval(stepInterval * Double(index + 1))
//
//      let newLog = TaskChangelog(
//        userId: "Rizky", // Mock user ID
//        taskId: self.id.uuidString,
//        date: changeDate,
//        statusBefore: statusBefore,
//        statusAfter: currentStatus,
//        description: "Status diubah menjadi \(currentStatus.displayName)." // Mock description
//      )
//      changelogs.append(newLog)
//    }
//
//    return changelogs
//  }
//}

//  private func generateRandomLocation() -> String {
//    let blocks = ["A", "B", "C", "D"]
//    let unitNumber = Int.random(in: 1...30)
//
//    // Safely unwrap the random element, defaulting to "A" if it somehow fails.
//    let block = blocks.randomElement() ?? "A"
//
//    return "Blok \(block) - \(unitNumber)"
//  }
//
//  let sampleTasks: [LandscapingTask] = [
//  // MARK: - Major Tasks
//  Plant Type: Pohon
//    LandscapingTask(title: "Pemangkasan Berat Pohon Angsana di Jl. Darmo", location: "Blok A5", description: "Fokus pada pemotongan dahan yang menjulur ke kabel listrik dan berpotensi patah saat angin kencang.", area: 10, unit: "m2", taskType: .major, plantType: .tree, plant_name: "Pinus Ganteng", status: .aktif, dueDate: Date(timeIntervalSince1970: 1751031933), dateCreated: Date(timeIntervalSince1970: 1750599933), dateModified: Date(timeIntervalSince1970: 1750945533), dateClosed: nil)
// LandscapingTask(title: "Perawatan Akar Pohon Trembesi Area Balai Kota", description: "Pemberian nutrisi khusus dan penggemburan tanah di sekitar akar untuk revitalisasi pohon bersejarah.", taskType: .major, plantType: .tree, status: .diajukan, dueDate: Date(timeIntervalSince1970: 1750869789), dateCreated: Date(timeIntervalSince1970: 1750005789), dateModified: Date(timeIntervalSince1970: 1750178589), dateClosed: nil),
// LandscapingTask(title: "Pemeriksaan Kesehatan Pohon Beringin Tua", description: "Evaluasi struktural dan kesehatan pohon oleh arboris bersertifikat, termasuk deteksi rongga batang.", taskType: .major, plantType: .tree, status: .diperiksa, dueDate: Date(timeIntervalSince1970: 1749372198), dateCreated: Date(timeIntervalSince1970: 1749112998), dateModified: Date(timeIntervalSince1970: 1749372198), dateClosed: nil),
// LandscapingTask(title: "Penanaman Kembali 50 Bibit Tabebuya", description: "Proyek penghijauan jalur pedestrian dengan bibit pohon Tabebuya kuning dan merah muda.", taskType: .major, plantType: .tree, status: .selesai, dueDate: Date(timeIntervalSince1970: 1750232541), dateCreated: Date(timeIntervalSince1970: 1749502941), dateModified: Date(timeIntervalSince1970: 1749675741), dateClosed: Date(timeIntervalSince1970: 1750021341)),
// LandscapingTask(title: "Relokasi Pohon Palem Raja Proyek Apartemen", description: "Proses pemindahan pohon setinggi 10 meter ke lokasi baru menggunakan alat berat.", taskType: .major, plantType: .tree, status: .terdenda, dueDate: Date(timeIntervalSince1970: 1752003859), dateCreated: Date(timeIntervalSince1970: 1751139459), dateModified: Date(timeIntervalSince1970: 1751571459), dateClosed: Date(timeIntervalSince1970: 1751830659)),
// LandscapingTask(title: "Pemberantasan Hama Ulat pada Pohon Mahoni", description: "Aplikasi insektisida biologis untuk mengatasi wabah ulat api yang merusak dedaunan secara masif.", taskType: .major, plantType: .tree, status: .dialihkan, dueDate: Date(timeIntervalSince1970: 1750444539), dateCreated: Date(timeIntervalSince1970: 1750098939), dateModified: Date(timeIntervalSince1970: 1750530939), dateClosed: nil),
// // Plant Type: Semak
// LandscapingTask(title: "Peremajaan Total Pagar Hidup Semak Teh-tehan", description: "Memangkas seluruh pagar hidup hingga 50 cm dari tanah untuk merangsang pertumbuhan tunas baru yang lebih rapat.", taskType: .major, plantType: .bush, status: .aktif, dueDate: Date(timeIntervalSince1970: 1750529149), dateCreated: Date(timeIntervalSince1970: 1749747949), dateModified: Date(timeIntervalSince1970: 1750093549), dateClosed: nil),
// LandscapingTask(title: "Desain Ulang Taman Bunga dengan Semak Soka", description: "Mengganti pola tanam semak soka dan menambahkan varietas baru untuk menciptakan gradasi warna.", taskType: .major, plantType: .bush, status: .diajukan, dueDate: Date(timeIntervalSince1970: 1751293111), dateCreated: Date(timeIntervalSince1970: 1750861111), dateModified: Date(timeIntervalSince1970: 1751120311), dateClosed: nil),
// LandscapingTask(title: "Pembentukan Topiary Semak Boxwood di Taman Prestasi", description: "Membentuk 20 semak boxwood menjadi bentuk hewan dan geometris sesuai rencana desain.", taskType: .major, plantType: .bush, status: .diperiksa, dueDate: Date(timeIntervalSince1970: 1750298668), dateCreated: Date(timeIntervalSince1970: 1750125868), dateModified: Date(timeIntervalSince1970: 1750557868), dateClosed: nil),
// LandscapingTask(title: "Penanaman Massal Semak Lantana di Median Jalan", description: "Menanam 2000 bibit semak lantana untuk meningkatkan estetika dan menarik kupu-kupu.", taskType: .major, plantType: .bush, status: .selesai, dueDate: Date(timeIntervalSince1970: 1749800488), dateCreated: Date(timeIntervalSince1970: 1749454888), dateModified: Date(timeIntervalSince1970: 1749800488), dateClosed: Date(timeIntervalSince1970: 1750232488)),
// LandscapingTask(title: "Pengendalian Penyakit Jamur pada Semak Mawar", description: "Aplikasi fungisida sistemik untuk mengatasi masalah bercak hitam dan karat daun pada populasi mawar.", taskType: .major, plantType: .bush, status: .terdenda, dueDate: Date(timeIntervalSince1970: 1751073050), dateCreated: Date(timeIntervalSince1970: 1750245050), dateModified: Date(timeIntervalSince1970: 1750677050), dateClosed: Date(timeIntervalSince1970: 1750936250)),
// LandscapingTask(title: "Rehabilitasi Area Semak Bougenville Pasca Proyek", description: "Memperbaiki dan menanam kembali semak bougenville yang rusak akibat aktivitas konstruksi di sekitarnya.", taskType: .major, plantType: .bush, status: .dialihkan, dueDate: Date(timeIntervalSince1970: 1750847008), dateCreated: Date(timeIntervalSince1970: 1749811408), dateModified: Date(timeIntervalSince1970: 1749984208), dateClosed: nil),
// // Plant Type: Ground Cover
// LandscapingTask(title: "Penggantian Rumput Gajah Mini Lapangan Hockey", description: "Membongkar lapisan rumput lama seluas 5000 m² dan memasang gulungan rumput baru.", taskType: .major, plantType: .groundCover, status: .aktif, dueDate: Date(timeIntervalSince1970: 1750121988), dateCreated: Date(timeIntervalSince1970: 1750035588), dateModified: Date(timeIntervalSince1970: 1750381188), dateClosed: nil),
// LandscapingTask(title: "Instalasi Sistem Irigasi Sprinkler Otomatis", description: "Memasang jaringan pipa bawah tanah dan 150 kepala sprinkler untuk area taman seluas 2 hektar.", taskType: .major, plantType: .groundCover, status: .diajukan, dueDate: Date(timeIntervalSince1970: 1749579803), dateCreated: Date(timeIntervalSince1970: 1749320603), dateModified: Date(timeIntervalSince1970: 1749752603), dateClosed: nil),
// LandscapingTask(title: "Aerasi dan Top Dressing Lapangan Sepak Bola", description: "Melakukan aerasi (pelubangan tanah) dan menambahkan lapisan pasir untuk memperbaiki drainase.", taskType: .major, plantType: .groundCover, status: .diperiksa, dueDate: Date(timeIntervalSince1970: 1750446014), dateCreated: Date(timeIntervalSince1970: 1749666014), dateModified: Date(timeIntervalSince1970: 1749925214), dateClosed: nil),
// LandscapingTask(title: "Restorasi Lereng dengan Rumput Vetiver", description: "Menanam rumput vetiver di area miring untuk stabilisasi tanah dan pencegahan erosi.", taskType: .major, plantType: .groundCover, status: .selesai, dueDate: Date(timeIntervalSince1970: 1751627893), dateCreated: Date(timeIntervalSince1970: 1750679893), dateModified: Date(timeIntervalSince1970: 1751111893), dateClosed: Date(timeIntervalSince1970: 1751457493)),
// LandscapingTask(title: "Pemberantasan Gulma di Area Arachis Pintoi", description: "Aplikasi herbisida selektif untuk membasmi rumput liar tanpa merusak tanaman penutup tanah utama.", taskType: .major, plantType: .groundCover, status: .terdenda, dueDate: Date(timeIntervalSince1970: 1750062984), dateCreated: Date(timeIntervalSince1970: 1749890184), dateModified: Date(timeIntervalSince1970: 1750062984), dateClosed: Date(timeIntervalSince1970: 1750408584)),
// LandscapingTask(title: "Penanaman Kembang Pukul Sembilan di Taman Lansia", description: "Menanam bedengan bunga Portulaca grandiflora sebagai ground cover berwarna-warni yang tahan panas.", taskType: .major, plantType: .groundCover, status: .dialihkan, dueDate: Date(timeIntervalSince1970: 1750844028), dateCreated: Date(timeIntervalSince1970: 1750240428), dateModified: Date(timeIntervalSince1970: 1750413228), dateClosed: nil),
// // MARK: - Minor Tasks
// // Plant Type: Pohon
// LandscapingTask(title: "Pemupukan Rutin Pohon Peneduh", description: "Pemberian pupuk NPK seimbang untuk semua pohon peneduh di sepanjang jalan protokol.", taskType: .minor, plantType: .tree, status: .aktif, dueDate: Date(timeIntervalSince1970: 1750487288), dateCreated: Date(timeIntervalSince1970: 1750314488), dateModified: Date(timeIntervalSince1970: 1750746488), dateClosed: nil),
// LandscapingTask(title: "Penyiraman Pohon Buah di Taman Kota", description: "Jadwal penyiraman harian menggunakan mobil tangki air untuk koleksi pohon buah.", taskType: .minor, plantType: .tree, status: .selesai, dueDate: Date(timeIntervalSince1970: 1751108517), dateCreated: Date(timeIntervalSince1970: 1750849317), dateModified: Date(timeIntervalSince1970: 1751022117), dateClosed: Date(timeIntervalSince1970: 1751367717)),
// LandscapingTask(title: "Pembersihan Gulma di Sekitar Perakaran Pohon", description: "Membersihkan area radius 1 meter dari pangkal pohon dari tanaman liar pengganggu.", taskType: .minor, plantType: .tree, status: .terdenda, dueDate: Date(timeIntervalSince1970: 1750536299), dateCreated: Date(timeIntervalSince1970: 1749845899), dateModified: Date(timeIntervalSince1970: 1750191499), dateClosed: Date(timeIntervalSince1970: 1750364299)),
// // Plant Type: Semak
// LandscapingTask(title: "Pemangkasan Ringan Semak Melati", description: "Merawat bentuk dan merapikan semak melati agar tetap terlihat rapi dan mendorong pembungaan.", taskType: .minor, plantType: .bush, status: .aktif, dueDate: Date(timeIntervalSince1970: 1750889321), dateCreated: Date(timeIntervalSince1970: 1750199321), dateModified: Date(timeIntervalSince1970: 1750372121), dateClosed: nil),
// LandscapingTask(title: "Pengecekan Hama Kutu Putih pada Pucuk Daun", description: "Inspeksi rutin dan penanganan dini serangan kutu putih pada pucuk-pucuk semak soka.", taskType: .minor, plantType: .bush, status: .selesai, dueDate: Date(timeIntervalSince1970: 1750168441), dateCreated: Date(timeIntervalSince1970: 1749909241), dateModified: Date(timeIntervalSince1970: 1750168441), dateClosed: Date(timeIntervalSince1970: 1750514041)),
// LandscapingTask(title: "Penambahan Mulsa Organik pada Semak Bunga", description: "Menambahkan lapisan kompos di sekitar pangkal semak untuk menjaga kelembaban tanah dan nutrisi.", taskType: .minor, plantType: .bush, status: .terdenda, dueDate: Date(timeIntervalSince1970: 1750791887), dateCreated: Date(timeIntervalSince1970: 1750007887), dateModified: Date(timeIntervalSince1970: 1750180687), dateClosed: Date(timeIntervalSince1970: 1750439887)),
// // Plant Type: Ground Cover
// LandscapingTask(title: "Pemotongan Rumput Hias Taman Depan Kantor", description: "Memotong rumput secara rutin menggunakan mesin potong untuk menjaga ketinggian ideal 3 cm.", taskType: .minor, plantType: .groundCover, status: .aktif, dueDate: Date(timeIntervalSince1970: 1751118061), dateCreated: Date(timeIntervalSince1970: 1750371661), dateModified: Date(timeIntervalSince1970: 1750803661), dateClosed: nil),
// LandscapingTask(title: "Penyiangan Manual Area Bunga Krokot", description: "Mencabut rumput liar secara manual di antara tanaman bunga agar tidak terganggu pertumbuhannya.", taskType: .minor, plantType: .groundCover, status: .selesai, dueDate: Date(timeIntervalSince1970: 1751197782), dateCreated: Date(timeIntervalSince1970: 1750592982), dateModified: Date(timeIntervalSince1970: 1750938582), dateClosed: Date(timeIntervalSince1970: 1751370582)),
// LandscapingTask(title: "Penyiraman Rumput Jepang di Area Gazebo", description: "Memastikan area rumput di sekitar gazebo mendapat pasokan air yang cukup di pagi hari.", taskType: .minor, plantType: .groundCover, status: .terdenda, dueDate: Date(timeIntervalSince1970: 1750369306), dateCreated: Date(timeIntervalSince1970: 1749764506), dateModified: Date(timeIntervalSince1970: 1750023706), dateClosed: Date(timeIntervalSince1970: 1750369306))
//  ]
//
//}
