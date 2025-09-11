//
//  TaskDetailView.swift
//  greenlake-companion
//
//  Created by Savio Enoson on 01/09/25.
//


import SwiftUI

struct TaskDetailView: View {
  @EnvironmentObject private var viewModel: AgendaViewModel
  @EnvironmentObject private var authManager: AuthManager
  var adminUsername: String {
    return authManager.currentUser?.name ?? "Admin"
  }
  @State private var showStatusSheet = false
  let task: LandscapingTask
  
  var body: some View {
    VStack(alignment: .leading, spacing: 30) {
      VStack(alignment: .leading, spacing: 20) {
        // Header
        HStack(alignment: .top) {
          Text(task.title)
            .font(.title)
            .fontWeight(.bold)
          
          Spacer()
          
          Menu {
            Button {
              Task {
                viewModel.pdfPreview = try await generateTaskReminder(taskToDraw: task, withSignTemplate: true)
              }
            } label: {
              Label("Berita Acara", systemImage: "text.document")
            }
            
            Button {
              Task {
                viewModel.pdfPreview = try await generateTaskReminder(taskToDraw: task)
              }
            } label: {
              Label("Pengingat", systemImage: "exclamationmark.bubble")
            }
          } label: {
              Text("Bagikan")
                      .font(.system(size: 16, weight: .medium))
                      .foregroundColor(.blue)
                      .padding(.horizontal, 16)
                      .padding(.vertical, 8)
                      .background(.blue.opacity(0.2))
                      .clipShape(Capsule())
                      .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 0)

          }
          
          Button {
             showStatusSheet = true
          } label: {
              Text("Ubah Status")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.blue)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.blue.opacity(0.2))
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 0)
          }
        }
        
        // Metadata Block
        VStack(alignment: .leading) {
          // Lokasi
          HStack {
              Text("Lokasi")
              .font(.subheadline)
              .foregroundColor(.secondary)
            
            Spacer()
            
            Text(task.location)
              .font(.subheadline)
              .foregroundColor(.primary)
              .bold()
          }
          
          // Tanaman
          HStack {
            Text("Tanaman")
              .font(.subheadline)
              .foregroundColor(.secondary)
            
            Spacer()
            
            Text(task.plant_name)
              .font(.subheadline)
              .foregroundColor(.primary)
              .bold()
          }
            
            HStack {
              Text("Jenis Tanaman")
                .font(.subheadline)
                .foregroundColor(.secondary)
              
              Spacer()
              
                Text(task.plantType.displayName)
                .font(.subheadline)
                .foregroundColor(.primary)
                .bold()
            }
          
          // Ukuran
          HStack {
            Text("Ukuran")
              .font(.subheadline)
              .foregroundColor(.secondary)
            
            Spacer()
            
            Text("\(String(format: "%.2f", task.area)) \(task.unit)")
              .font(.subheadline)
              .foregroundColor(.primary)
              .bold()
          }
          
          // Deadline
          HStack {
            Text("Tenggat Waktu")
              .font(.subheadline)
              .foregroundColor(.secondary)
            
            Spacer()
            
            let dueDateStr = dateFormatter.string(from: task.dueDate)
            Text("\(task.urgencyLabel.displayName)\t(\(dueDateStr))")
              .font(.subheadline)
              .foregroundColor(.primary)
              .bold()
          }
          
          // Status
          HStack {
            Text("Status Pekerjaan")
              .font(.subheadline)
              .foregroundColor(.secondary)
            
            Spacer()
            
            Text(task.status.displayName)
              .font(.subheadline)
              .foregroundColor(.primary)
              .bold()
          }
        }
        .frame(maxWidth: 350)
        
        // Details
        VStack(alignment: .leading) {
          Text("Deskripsi Pekerjaan")
            .font(.subheadline)
            .foregroundColor(.secondary)
          
          Text(task.description)
            .font(.subheadline)
            .padding(10)
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
      }
      
      // Timeline
      TaskTimelineView(task: task)
    }
    .padding()
    .padding(.bottom, 50)
    .sheet(isPresented: $showStatusSheet) {
        TaskStatusSheet(taskId: task.id)
    }
    
    .sheet(item: $viewModel.pdfPreview) { _ in
        PreviewPDFSheet()
        .background(.ultraThinMaterial)
    }.presentationDetents([.large])
  }
  
  private func generateTaskReminder(taskToDraw: LandscapingTask, withSignTemplate: Bool = false) async throws -> PDFDataWrapper {
    let pdfBuilder = PDFBuilder()
    let taskService = TaskService()
    let reportTitle = "INFORMASI PEKERJAAN"
    do {
      let imagesDictionary = try await taskService.fetchImages(for: [taskToDraw])
      
      let pdfData = pdfBuilder.createPDF { pdf in
        pdf.drawHeader(title: reportTitle, sender: adminUsername, date: Date())
        pdf.drawTaskReminder(task: taskToDraw, images: imagesDictionary, withSignTemplate: withSignTemplate)
      }
      return PDFDataWrapper(data: pdfData)
      
    } catch {
      throw PDFGenerationError.invalidImageData
    }
  }
}
