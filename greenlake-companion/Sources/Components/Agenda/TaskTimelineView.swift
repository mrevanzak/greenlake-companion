//
//  TaskTimelineView.swift
//  greenlake-companion
//
//  Created by Savio Enoson on 02/09/25.
//

import SwiftUI

struct TaskTimelineView: View {
  let task: LandscapingTask

  //  @State private var highlightedImage: Image?

  var body: some View {
    ScrollView {
      LazyVStack(alignment: .leading, spacing: 0) {
        ForEach(task.taskTimeline.reversed()) { entry in
          HStack(alignment: .top, spacing: 16) {
            TimelineIndicator(status: entry.statusAfter, isLast: entry.statusBefore == nil)

            TimelineEntryView(entry: entry)
              .padding(.bottom, 60)
          }
        }
      }
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
          Text(entry.statusBefore?.displayName ?? "Dibuat")
            .font(.headline)
            .bold()
            .foregroundColor(entry.statusBefore?.displayColor ?? .secondary)

          Spacer()

          Image(systemName: "arrow.right")
            .font(.headline)

          Spacer()

          Text(entry.statusAfter.displayName)
            .font(.headline)
            .bold()
            .foregroundColor(entry.statusAfter.displayColor)
        }
        .frame(maxWidth: 200)

        // Image Carousel
        if let images = entry.images, !images.isEmpty {
          ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
              ForEach(images.indices, id: \.self) { index in
                Image(uiImage: images[index])
                  .resizable()
                  .scaledToFit()
                  .frame(height: 200)
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

              Text(entry.userId)
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

              Text(dateFormatter.string(from: entry.date))
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
}
