import SwiftUI
import SwiftUIX

struct URLWrapper: Identifiable {
  let id = UUID()  // A unique ID for each instance
  let url: URL
}

enum PDFReportType: String, Identifiable {
  var id: String { self.rawValue }
  
  case checklist = "Checklist Pekerjaan"
  case fine = "Laporan Denda"
  case information = "Informasi Pekerjaan"
  case report = "Berita Acara"
}

struct PreviewPDFSheet: View {
  private let sheetMinWidth = UIScreen.main.bounds.width - 100
  @State private var pdfPreview: PDFDataWrapper? = nil
  @State private var shareableURL: URLWrapper?
  @State private var excludedTasks: [LandscapingTask] = []
  @State private var debounceTask: Task<Void, Never>?
  
  @EnvironmentObject private var authManager: AuthManager
  var adminUsername: String {
    return authManager.currentUser?.name ?? "Admin"
  }
  
  @StateObject private var viewModel = AgendaViewModel.shared
  
  var body: some View {
    VStack(spacing: 0) {
      HStack {
        Button("Batal", action: reset)
          .foregroundColor(Color(.systemRed))
        
        Spacer()
        
        Text("\(viewModel.requestedExportType?.rawValue ?? "Preview")")
        
        Spacer()
        
        Button("Bagikan", action: saveAndSharePDF)
          .foregroundColor(Color(.systemBlue))
      }
      .fontWeight(.semibold)
      .padding()
      
      HStack(spacing: 8) {
        if viewModel.requestedExportType == .checklist || viewModel.requestedExportType == .fine {
          // --- Left Column ---
          VStack(alignment: .leading) {
            Text("Daftar Pekerjaan")
              .font(.headline)
              .fontWeight(.bold)
            
            if viewModel.tasksToExport != nil {
              ScrollView {
                ForEach(viewModel.tasksToExport!) { task in
                  let isExcluded = excludedTasks.contains(task)
                  
                  HStack(spacing: 16) {
                    Image(systemName: isExcluded ? "circle" : "checkmark.circle.fill")
                      .font(.title3)
                      .foregroundColor(isExcluded ? .gray : Color(.systemBlue))
                    
                    TaskPreview(task: task)
                      .padding(.vertical)
                  }
                  .contentShape(Rectangle())
                  .onTapGesture {
                    toggleTaskExclusion(for: task)
                  }
                }
              }
            } else {
              Text("Sedang memuat daftar pekerjaan...")
            }
          }
          .padding()
          .frame(maxWidth: sheetMinWidth * 0.34)
          .background(Color(.systemBackground))
          .cornerRadius(8)
        }
        
        // --- Right Column ---
        VStack {
          if let currentPDF = pdfPreview {
            PDFKitView(data: currentPDF.data)
          } else {
            VStack {
              ActivityIndicator()
              Text("Sedang menyusun PDF...")
            }
            .foregroundColor(Color(.systemGray))
          }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.secondary)
        .cornerRadius(8)
      }
    }
    .interactiveDismissDisabled()
    
    .padding(.horizontal, 8)
    .padding(.bottom, 8)
    .frame(minWidth: sheetMinWidth)
    .background(.ultraThinMaterial)
    .sheet(item: $shareableURL) { wrapper in
      let shareText = generateShareText()
      ShareSheet(activityItems: [shareText, wrapper.url])
    }
    
    .onDisappear {
      reset()
    }
    .task {
      await populatePreview()
    }
    .onChange(of: excludedTasks) {
      // Cancel the previous task to reset the timer
      debounceTask?.cancel()
      
      // Schedule a new task to run after a 2-second delay
      debounceTask = Task {
        do {
          try await Task.sleep(for: .seconds(2))
          
          pdfPreview = nil
          await populatePreview()
        } catch {
          print("refresh cancelled")
        }
      }
    }
  }
  
  private func populatePreview() async {
    do {
      switch viewModel.requestedExportType {
      case .checklist:
        pdfPreview = try await generateTaskChecklistPDF()
      case .fine:
        pdfPreview = try await generateFinePDF()
      case .information:
        pdfPreview = try await generateTaskReminder()
      case .report:
        pdfPreview = try await generateTaskReminder(withSignTemplate: true)
      default:
        return
      }
    } catch {
      print("Failed to generate PDF: \(error.localizedDescription)")
    }
  }
  
  private func reset() {
    debounceTask?.cancel()
    excludedTasks.removeAll()
    viewModel.requestedExportType = nil
    viewModel.tasksToExport = nil
  }
  
  private func toggleTaskExclusion(for task: LandscapingTask) {
    if let index = excludedTasks.firstIndex(of: task) {
      excludedTasks.remove(at: index)
    } else {
      excludedTasks.append(task)
    }
  }
  
  private func excludeTasksFromList(from listB: [LandscapingTask], basedOn listA: [LandscapingTask]) -> [LandscapingTask] {
    let exclusionSet = Set(listA)
    
    let filteredList = listB.filter { task in
      !exclusionSet.contains(task)
    }
    
    return filteredList
  }
  
  private func generateShareText() -> String {
    return ""
//    var message = "\(viewModel.requestedExportType?.rawValue ?? "Laporan")"
//    message += "Tanggal: \(dateFormatter.string(from: Date()))\n"
//    guard var tasksToDraw = viewModel.tasksToExport else { return "" }
//
//    switch viewModel.requestedExportType {
//    case .checklist:
//      var index = 1
//      
//      if !excludedTasks.isEmpty {
//        tasksToDraw = excludeTasksFromList(from: tasksToDraw, basedOn: excludedTasks)
//      }
//      for taskItem in tasksToDraw {
//        message += """
//        \(index). \(taskItem.title)
//          Tanaman: \(taskItem.plant_name)
//          Lokasi: \(taskItem.location)
//          Tenggat Waktu: \(dateFormatter.string(from: taskItem.dueDate))
//          \n
//        """
//        index += 1
//      }
//      break
////    case .fine:
////      
////    case .information:
////      
////    case .report:
//      
//    default: break
//    }
//    
//    return message
  }
  
  
  private func saveAndSharePDF() {
    guard let pdfData = pdfPreview?.data else {
      print("Gagal memuat data PDF.")
      return
    }
    
    let fileName = "\(viewModel.requestedExportType?.rawValue ?? "Laporan")-\(dateFormatter.string(from: Date())).pdf"
    
    if let url = saveToTemporaryDirectory(data: pdfData, fileName: fileName) {
      self.shareableURL = URLWrapper(url: url)
    }
  }
  
  private func saveToTemporaryDirectory(data: Data, fileName: String) -> URL? {
    let temporaryDirectoryURL = FileManager.default.temporaryDirectory
    let fileURL = temporaryDirectoryURL.appendingPathComponent(fileName)
    
    do {
      try data.write(to: fileURL)
      return fileURL
    } catch {
      print("Error saving file: \(error.localizedDescription)")
      return nil
    }
  }
  
  private func generateTaskChecklistPDF() async throws -> PDFDataWrapper
  {
    let pdfBuilder = PDFBuilder()
    let taskService = TaskService()
    let reportTitle = "REKAPITULASI PEKERJAAN"
    
    if (viewModel.tasksToExport == nil) {
      // Only show active tasks
      let allowedStatuses: Set<TaskStatus> = [.diajukan, .aktif, .diperiksa]
      // Select all valid tasks as the current focus if the list was empty
      viewModel.tasksToExport = viewModel.tasks.filter { task in
        allowedStatuses.contains(task.status)
      }
    }
    
    guard var tasksToDraw = viewModel.tasksToExport else { throw PDFGenerationError.invalidGenerationSequence }
    
    if !excludedTasks.isEmpty {
      tasksToDraw = excludeTasksFromList(from: tasksToDraw, basedOn: excludedTasks)
    }
    
    do {
      let imagesDictionary = try await taskService.fetchImages(for: tasksToDraw)
      
      let pdfData = pdfBuilder.createPDF { pdf in
        pdf.drawHeader(title: reportTitle, sender: adminUsername, date: Date())
        pdf.drawTasks(tasks: tasksToDraw, images: imagesDictionary)
      }
      return PDFDataWrapper(data: pdfData)
      
    } catch {
      throw PDFGenerationError.invalidImageData
    }
  }
  
  private func generateFinePDF() async throws -> PDFDataWrapper {
    let pdfBuilder = PDFBuilder()
    let reportTitle = "LAPORAN KETERLAMBATAN"
    
    if (viewModel.tasksToExport == nil) {
      // Only show tasks closed past the due date.
      viewModel.tasksToExport = viewModel.tasks.filter { task in
        guard let closedDate = task.dateClosed else { return false }
        return closedDate > task.dueDate
      }
    }
    
    guard var tasksToDraw = viewModel.tasksToExport else { throw PDFGenerationError.invalidGenerationSequence }
    
    if !excludedTasks.isEmpty {
      tasksToDraw = excludeTasksFromList(from: tasksToDraw, basedOn: excludedTasks)
    }
    
    let pdfData = pdfBuilder.createPDF { pdf in
      pdf.drawHeader(title: reportTitle, sender: adminUsername, date: Date())
      pdf.drawFineTable(finedTasks: tasksToDraw)
    }
    
    return PDFDataWrapper(data: pdfData)
  }
  
  private func generateTaskReminder(withSignTemplate: Bool = false) async throws -> PDFDataWrapper {
    let pdfBuilder = PDFBuilder()
    let taskService = TaskService()
    let reportTitle = "INFORMASI PEKERJAAN"
    
    guard let tasksToDraw = viewModel.tasksToExport else { throw PDFGenerationError.invalidGenerationSequence }
    do {
      let imagesDictionary = try await taskService.fetchImages(for: tasksToDraw)
      
      let pdfData = pdfBuilder.createPDF { pdf in
        pdf.drawHeader(title: reportTitle, sender: adminUsername, date: Date())
        pdf.drawTaskReminder(task: tasksToDraw[0], images: imagesDictionary, withSignTemplate: withSignTemplate)
      }
      return PDFDataWrapper(data: pdfData)
      
    } catch {
      throw PDFGenerationError.invalidImageData
    }
  }
}
