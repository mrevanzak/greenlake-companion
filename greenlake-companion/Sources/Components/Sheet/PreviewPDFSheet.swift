import SwiftUI

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
  private let tasksToExport: [LandscapingTask] = []
  private var pdfPreview: PDFDataWrapper? = nil
  @State private var shareableURL: URLWrapper?

  @EnvironmentObject private var authManager: AuthManager
  var adminUsername: String {
    return authManager.currentUser?.name ?? "Admin"
  }

  @StateObject private var viewModel = AgendaViewModel.shared

  var body: some View {
    VStack(spacing: 0) {
      HStack {
        Button("Batal") {
          viewModel.requestedExportType = nil
        }
        .foregroundColor(Color(.systemRed))

        Spacer()

        Text("Preview")

        Spacer()

        Button {
          saveAndSharePDF()
        } label: {
          Image(systemName: "square.and.arrow.up")
            .font(.title3)
        }
      }
      .padding()

      Divider()

      HStack(spacing: 0) {
        // --- Left Column ---
        VStack {
          Text("Controls")
            .font(.headline)
            .padding(.top)

          List(1..<11) { item in
            Text("Task \(item)")
          }
          .background(.clear)
        }
        .frame(maxWidth: sheetMinWidth * 0.34)
        .background(.clear)

        // --- Right Column ---
        VStack {
          if let currentPDF = pdfPreview {
            PDFKitView(data: currentPDF.data)
          } else {
            EmptyView()
          }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.secondary)
      }
    }
    .frame(minWidth: sheetMinWidth)
    .sheet(item: $shareableURL) { wrapper in
      ShareSheet(activityItems: [wrapper.url])
    }
  }

  private func populatePreview() {

  }

  private func saveAndSharePDF() {
    guard let pdfData = pdfPreview?.data else {
      print("PDF data is not available.")
      return
    }

    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
    let fileName = "Report-\(formatter.string(from: Date())).pdf"

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

  private func generateTaskChecklistPDF(tasksToDraw: [LandscapingTask]) async throws
    -> PDFDataWrapper
  {
    let pdfBuilder = PDFBuilder()
    let taskService = TaskService()
    let reportTitle = "REKAPITULASI PEKERJAAN"
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

  private func generateFinePDF(tasksToDraw: [LandscapingTask]) async -> PDFDataWrapper {
    let pdfBuilder = PDFBuilder()
    let reportTitle = "LAPORAN KETERLAMBATAN"

    // Filter tasks closed after its due date
    let lateClosedTasks = tasksToDraw.filter { task in
      guard let closedDate = task.dateClosed else { return false }
      return closedDate > task.dueDate
    }

    let pdfData = pdfBuilder.createPDF { pdf in
      pdf.drawHeader(title: reportTitle, sender: adminUsername, date: Date())
      pdf.drawFineTable(finedTasks: lateClosedTasks)
    }

    return PDFDataWrapper(data: pdfData)
  }
}
