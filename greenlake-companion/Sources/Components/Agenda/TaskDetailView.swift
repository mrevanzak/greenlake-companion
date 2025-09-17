//
//  TaskDetailView.swift
//  greenlake-companion
//
//  Created by Savio Enoson on 01/09/25.
//


import SwiftUI

struct TaskDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var tabManager: TabSelectionManager
  @StateObject private var viewModel = AgendaViewModel.shared

  @EnvironmentObject private var authManager: AuthManager
  var adminUsername: String {
    return authManager.currentUser?.name ?? "Admin"
  }
  @State private var showStatusSheet = false
  let task: LandscapingTask
  
  var body: some View {
    VStack(alignment: .leading, spacing: 35) {
        VStack(alignment: .leading, spacing: 35) {
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    if tabManager.isOnMapTab {
                        Text("Lihat di agenda")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(.thinMaterial)
                            .clipShape(Capsule())
                            .shadow(color: .black.opacity(0.07), radius: 10, x: 7, y: 7)
                    }
                    Spacer()
                    Menu {
                        Button {
                            Task {
                                viewModel.requestedExportType = .report
                                viewModel.tasksToExport = [task]
                            }
                        } label: {
                            Label("Berita Acara", systemImage: "text.document")
                        }
                        
                        Button {
                            Task {
                                viewModel.requestedExportType = .information
                                viewModel.tasksToExport = [task]
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
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 7, y: 7)

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
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 7, y: 7)
                    }
                    if tabManager.isOnMapTab {
                        
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
//                                .background(.thinMaterial)
//                                .clipShape(Capsule())
//                                .shadow(color: .black.opacity(0.07), radius: 10, x: 7, y: 7)
                        }
                    }
                }
                .padding(.horizontal, -4)
//                .padding(.vertical, 8)
                
                    Text(task.title)
                        .font(.title)
                        .fontWeight(.bold)

                HStack(spacing : 24) {
                    Text(task.status.displayName)
                        .foregroundColor(.purple)
                        .font(.system(size: 16, weight: .medium))
                        .cornerRadius(20)
                   
                    let dueDateStr = dateFormatter.string(from: task.dueDate)
                    Text("\(task.urgencyLabel.displayName)\t(\(dueDateStr))")
                        .foregroundColor(.red)
                        .font(.system(size: 16, weight: .medium))
                        .cornerRadius(20)

                }
            }
            VStack(alignment: .leading, spacing: 16) {
                // Metadata Block
                HStack(alignment: .top, spacing: 40) {
                    // Tanaman
                    VStack(alignment: .leading) {
                        Text("Tanaman")
                            .font(.system(size: 14, weight: .medium))
                            .italic()
                            .foregroundColor(.secondary)
                        
                        Text(task.plant_name)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                            .bold()
                    }
                    // Lokasi
                    VStack(alignment: .leading) {
                        Text("Lokasi")
                            .font(.system(size: 14, weight: .medium))
                            .italic()
                            .foregroundColor(.secondary)
                        Text(task.location)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                            .bold()
                    }
                    VStack(alignment: .leading) {
                        Text("Jenis")
                            .font(.system(size: 14, weight: .medium))
                            .italic()
                            .foregroundColor(.secondary)
                        Text(task.plantType.displayName)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                            .bold()
                    }
                    // Ukuran
                    VStack(alignment: .leading) {
                        Text("Ukuran")
                            .font(.system(size: 14, weight: .medium))
                            .italic()
                            .foregroundColor(.secondary)
                        Text("\(String(format: "%.2f", task.area)) \(task.unit)")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                            .bold()
                    }
                }
                
                // Details
                VStack(alignment: .leading, spacing: 6) {
                    Text("Deskripsi Pekerjaan")
                        .font(.system(size: 14, weight: .medium))
                        .italic()
                        .foregroundColor(.secondary)
                    
                    Text(task.description)
                        .font(.system(size: 14, weight: .medium))
//                        .padding(.horizontal, 12)
//                        .padding(.vertical, 8)
//                        .background(.regularMaterial)
//                        .cornerRadius(20)
                    //            .overlay(
                    //                  RoundedRectangle(cornerRadius: 20)
                    //                    .stroke(Color.primary.opacity(0.3), lineWidth: 1)
                    //                  )
                }
            }
        }
        .padding()
//        .padding(.bottom, 50)
//        .clipShape(UnevenRoundedRectangle(cornerRadii: .init(
//                topLeading: 20,
//                bottomLeading: 0,
//                bottomTrailing: 0,
//                topTrailing: 20
//            )))
            
        // Timeline
      TaskTimelineView(task: task)
//            .padding()
//            .padding(.bottom, 50)
    }
    
    .sheet(isPresented: $showStatusSheet) {
        TaskStatusSheet(taskId: task.id)
    }
  }
}

#Preview {
    TaskDetailView(task: LandscapingTask(
        id: UUID(),
        title: "Penanaman Rumput Lapangan Utama",
        location: "Blok A5",
        description: "Melakukan penanaman rumput bermuda pada area lapangan utama dengan.",
        area: 125.50,
        unit: "m²",
        taskType: .major,
        plantType: PlantType.tree,
        plant_name: "Rumput Bermuda",
        status: .aktif,
        dueDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
        dateCreated: Date(),
        dateModified: Date(),
        dateClosed: nil
    ))
    .environmentObject(AuthManager.shared)
    .environmentObject(TabSelectionManager(selectedTabIndex: .constant(0)))

}
