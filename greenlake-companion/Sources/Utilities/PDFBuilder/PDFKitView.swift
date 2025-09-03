//
//  PDFKitView.swift
//  greenlake-companion
//
//  Created by Savio Enoson on 02/09/25.
//


import SwiftUI
import PDFKit

// A simple UIViewRepresentable to show the PDF in SwiftUI
struct PDFKitView: UIViewRepresentable {
  let data: Data
  
  func makeUIView(context: Context) -> PDFView {
    let pdfView = PDFView()
    pdfView.document = PDFDocument(data: data)
    pdfView.autoScales = true
    return pdfView
  }
  
  func updateUIView(_ uiView: PDFView, context: Context) {
    // No update needed
  }
}

// A wrapper to make Data identifiable for the .sheet modifier
struct PDFDataWrapper: Identifiable {
  let id = UUID()
  let data: Data
}

struct PDFSampleView: View {
  @State private var pdfPreview: PDFDataWrapper?
  
  var body: some View {
    VStack {
      Menu {
        Button("Checklist Harian", action: generateTaskChecklistPDF)
        Button("Laporan Denda", action: generateFinePDF)
        Button("Reminder Task", action: generateTaskReminder)
        Button("Berita Acara", action: { print("Option C selected") })
      } label: {
        HStack{
          Text("Generate PDF Files")
          Divider()
          Image(systemName: "chevron.down")
        }
        .frame(height: 120)
        .padding(.horizontal, 20)
        .foregroundColor(.white)
        .background(.blue)
        .cornerRadius(10)
      }
      .font(.largeTitle)
    }
//    .task {
    //    }
//      generatePDF()
    .padding()
    .sheet(item: $pdfPreview) { pdfDataWrapper in
      NavigationView {
        PDFKitView(data: pdfDataWrapper.data)
          .navigationTitle("PDF Preview")
          .navigationBarTitleDisplayMode(.inline)
          .toolbar {
            ToolbarItem(placement: .cancellationAction) {
              Button("Close") {
                self.pdfPreview = nil
              }
            }
          }
      }
    }
  }
  
  private func generateTaskChecklistPDF() {
    let reportTitle = "REKAPITULASI PEKERJAAN"
    let creator = PDFBuilder()
    let pdfData = creator.createPDF { pdf in
      pdf.drawHeader(title: reportTitle, sender: "Akmal", date: Date())
      
      let tasksToDraw = Array(sampleTasks.prefix(5))
      pdf.drawTasks(tasks: tasksToDraw)
    }
    
    self.pdfPreview = PDFDataWrapper(data: pdfData)
  }
  
  private func generateFinePDF() {
    let reportTitle = "LAPORAN KETERLAMBATAN"
    let creator = PDFBuilder()
    let pdfData = creator.createPDF { pdf in
      pdf.drawHeader(title: reportTitle, sender: "Akmal", date: Date())
      
      let lateClosedTasks = sampleTasks.filter { task in
          guard let closedDate = task.dateClosed else {
              return false
          }
          return closedDate > task.dueDate
      }
      let tasksToDraw = Array(lateClosedTasks.prefix(10))
      
      pdf.drawFineTable(finedTasks: tasksToDraw)
    }
    
    self.pdfPreview = PDFDataWrapper(data: pdfData)
  }
  
  private func generateTaskReminder() {
    let reportTitle = "INFORMASI PEKERJAAN"
    let creator = PDFBuilder()
    let pdfData = creator.createPDF { pdf in
      pdf.drawHeader(title: reportTitle, sender: "Akmal", date: Date())
      
      let taskToDraw = sampleTasks[Int.random(in: 1...sampleTasks.count)]
      pdf.drawTaskReminder(task: taskToDraw)
    }
    
    self.pdfPreview = PDFDataWrapper(data: pdfData)
  }
}

// This block allows you to see the UI in Xcode's canvas
#Preview {
  PDFSampleView()
}
