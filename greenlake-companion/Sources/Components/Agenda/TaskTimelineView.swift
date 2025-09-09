//
//  TaskTimelineView.swift
//  greenlake-companion
//
//  Created by Savio Enoson on 02/09/25.
//

import SwiftUI

struct TaskTimelineView: View {
  let task: LandscapingTask
  
  @State private var timeline: [TaskChangelog] = []
  @State private var isLoading = false
  @State private var errorMessage: String?
  
  private let taskService = TaskService()
  
  var body: some View {
    Group {
      if isLoading {
        ProgressView("Memuat timeline...")
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      } else if let errorMessage = errorMessage {
        Text("❌ \(errorMessage)")
          .foregroundColor(.red)
          .multilineTextAlignment(.center)
          .padding()
      } else {
        ScrollView {
          LazyVStack(alignment: .leading, spacing: 0) {
            ForEach(Array(timeline.reversed()), id: \.id) { (entry: TaskChangelog) in
                HStack(alignment: .top, spacing: 16) {
                  TimelineIndicator(status: entry.toStatusEnum, isLast: entry.fromStatus?.isEmpty ?? true)
                    TimelineEntryView(entry: entry)
                        .padding(.bottom, 60)
                }
            }
          }
          .padding()
        }
      }
    }
    .task(id: task.id) {  
      print("🔍 TaskTimelineView task changed: \(task.id)")
      await loadTimeline()
    }
  }
  
  private func loadTimeline() async {
    isLoading = true
    do {
      self.timeline = try await taskService.fetchTimeline(id: task.id)
      self.errorMessage = nil
    } catch {
      self.errorMessage = error.localizedDescription
    }
    isLoading = false
  }
}

struct TimelineIndicator: View {
  let status: TaskStatus
  let isLast: Bool
  
  private let circleSize: CGFloat = 40
  private let lineWidth: CGFloat = 3
  
  var body: some View {
    VStack(spacing: 0) {
      ZStack {
        Circle()
          .fill(status.displayColor)
          .frame(width: circleSize, height: circleSize)
        
        Image(systemName: status.iconName)
          .foregroundColor(.white)
          .font(.headline.weight(.bold))
      }
      
      if !isLast {
        Rectangle()
          .fill(.secondary)
          .frame(width: lineWidth)
      }
    }
  }
}

struct TimelineEntryView: View {
  let entry: TaskChangelog
  
  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack {
        Text(entry.fromStatusEnum?.displayName ?? "Dibuat")
              .font(.headline)
              .bold()
              .foregroundColor(entry.fromStatusEnum?.displayColor ?? .secondary)

          Spacer()

          Image(systemName: "arrow.right")
              .font(.headline)

          Spacer()

          Text(entry.toStatusEnum.displayName)
              .font(.headline)
              .bold()
              .foregroundColor(entry.toStatusEnum.displayColor)
      }
      .frame(maxWidth: 200)
      
      // Image Carousel
      if !entry.photos.isEmpty {
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 20) {
            ForEach(Array(entry.photos.enumerated()), id: \.element) { index, photo in
              TappableAsyncImage(
                photo: photo,
                images: entry.photos,
                selectedIndex: index
              )
            }
          }
        }
      }
      
      VStack(alignment: .leading, spacing: 20) {
        // Header (status change, admin, time)
        VStack(alignment: .leading) {
          // Penanggungjawab
          HStack {
            Text("Penanggungjawab")
              .font(.subheadline)
              .foregroundColor(.secondary)
            
            Spacer()
            
            Text(entry.author)
              .font(.subheadline)
              .foregroundColor(.primary)
              .bold()
          }
          
          // Tanggal changelog
          HStack {
            Text("Tanggal")
              .font(.subheadline)
              .foregroundColor(.secondary)
            
            Spacer()
            
            Text(dateFormatter.string(from: entry.createdAt))
              .font(.subheadline)
              .foregroundColor(.primary)
              .bold()
          }
        }
        .frame(maxWidth: 300)
        
        // Notes
        VStack(alignment: .leading) {
          Text("Catatan")
            .font(.subheadline)
            .foregroundColor(.secondary)
          
          Text(entry.description ?? "")
            .font(.subheadline)
            .padding(10)
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
      }
    }
    .padding(.leading, 20)
  }
}
