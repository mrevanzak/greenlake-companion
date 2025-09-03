//
//  TaskDetailView.swift
//  greenlake-companion
//
//  Created by Savio Enoson on 01/09/25.
//


import SwiftUI

struct TaskDetailView: View {
  let task: LandscapingTask
  
  var body: some View {
    VStack(alignment: .leading, spacing: 30) {
      VStack(alignment: .leading, spacing: 20) {
        // Header
        HStack(alignment: .bottom) {
          Text(task.title)
            .font(.title)
            .fontWeight(.bold)
          
          Spacer()
          
          Menu {
            Button("Option A", action: { print("Option A selected") })
            Button("Option B", action: { print("Option B selected") })
            Button("Option C", action: { print("Option C selected") })
            
          } label: {
            HStack{
              Text("Ubah Status")
              Divider()
              Image(systemName: "chevron.down")
            }
            .frame(height: 40)
            .padding(.horizontal, 10)
            .foregroundColor(.white)
            .background(.blue)
            .cornerRadius(10)
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
            
            Text(task.plantName)
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
          Text("Catatan")
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
  }
}
