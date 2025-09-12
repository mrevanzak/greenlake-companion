//
//  SheetContentViews.swift
//  greenlake-companion
//
//  Created by Revan on 26/08/25.
//

import BottomSheet
import CoreLocation
import MapKit
import SwiftUI
import SwiftUIX

//MARK: - Sheet Content
struct MainSheetContentView: View {
  @StateObject private var viewModel = ActiveTasksViewModel()
  @StateObject private var plantManager = PlantManager.shared

  private struct LandscapeInfo {
    let title: String
    let value: String
  }

  private var landscapeData: [LandscapeInfo] {
    [
      .init(title: "Jumlah Pohon", value: "1020"),
      .init(title: "Area Hijau", value: "4827m²"),
      .init(title: "Jumlah Spesies", value: "389"),
      .init(title: "Area Ground Cover", value: "2711m²"),
    ]
  }

  private func buildCard(title: String, value: String) -> some View {
    VStack(alignment: .leading, spacing: 0) {
      Text(title)
        .font(.system(size: 16, weight: .medium))
        .foregroundColor(.black)
      Text(value)
        .font(.system(size: 45, weight: .black))
        .fontWidth(.compressed)
        .foregroundColor(Color(hue: 0.09, saturation: 0, brightness: 0.2, opacity: 1))
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.vertical, 12)
    .padding(.horizontal, 18)
    .background(Color.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 20))
    .overlay(
      RoundedRectangle(cornerRadius: 20)
        .strokeBorder(Color.white.opacity(0.7), lineWidth: 1)
    )
    .shadow(color: .black.opacity(0.2), radius: 8, x: 2, y: 2)
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 40) {
      VStack(alignment: .leading) {
        Text("Informasi Landscape")
          .font(.system(size: 16, weight: .semibold))
          .italic()
          .foregroundColor(.secondary)

        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
          buildCard(title: "Total Pohon", value: plantManager.getCount(for: "tree"))
          buildCard(title: "Total Semak", value: plantManager.getCount(for: "bush"))
          buildCard(title: "Ground Cover", value: plantManager.getCount(for: "ground_cover"))
          buildCard(title: "Total Tanaman", value: plantManager.totalPlantCount)
        }
      }

      VStack(alignment: .leading) {
        Text("Informasi Pekerjaan")
          .font(.system(size: 16, weight: .semibold))
          .italic()
          .foregroundColor(.secondary)

        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
          buildCard(title: "Pekerjaan Aktif", value: "\(viewModel.taskSummary?.activeTask ?? 0)")
          buildCard(title: "Diajukan", value: "\(viewModel.taskSummary?.diajukanTask ?? 0)")
          buildCard(title: "Diperiksa", value: "\(viewModel.taskSummary?.diperiksaTask ?? 0)")
          buildCard(
            title: "Mendekati Deadline", value: "\(viewModel.taskSummary?.approachingDeadline ?? 0)"
          )
        }
      }

      VStack(alignment: .leading) {
        Text("Pekerjaan Aktif")
          .font(.system(size: 16, weight: .semibold))
          .italic()
          .foregroundColor(.secondary)

        Group {
          if viewModel.isLoading {
            ProgressView("Memuat...")
          } else if let msg = viewModel.errorMessage {
            Text(msg)
              .foregroundColor(.red)
          } else if viewModel.activeTasks.isEmpty {
            Text("Tidak ada pekerjaan aktif.")
              .foregroundColor(.secondary)
          } else {
            ForEach(viewModel.activeTasks) { task in
              ActiveTaskRow(task: task)
            }
          }
        }
      }
    }
    .padding(.horizontal)
    .padding(.top, 24)
    .task {
      await viewModel.load()
      await plantManager.loadPlantCounts()
    }
  }
}

struct ActiveTaskRow: View {
  let task: LandscapingTask

  @State private var showingTaskDetailPopover = false

  var background: Color {
    switch task.status {
    case .diperiksa:
      return .orange
    case .diajukan:
      return .red
    default:
      return .green
    }
  }

  var body: some View {
    HStack {
      VStack(alignment: .leading) {
        Text(task.title)
          .font(.system(size: 16, weight: .medium))
          .foregroundColor(.white)

        Text(task.status.displayName)
          .font(.system(size: 16, weight: .medium))
          .foregroundColor(.white)
      }
      Spacer()
    }
    .padding(.vertical, 12)
    .padding(.horizontal, 18)
    .background(background, in: RoundedRectangle(cornerRadius: 20))  // Use urgencyStatus to determine background color
    .overlay(
      RoundedRectangle(cornerRadius: 20)
        .strokeBorder(Color.white.opacity(0.3), lineWidth: 1)
    )
    .shadow(color: .black.opacity(0.2), radius: 16, x: 10, y: 10)
    .contentShape(Rectangle())
    .onTapGesture {
      print("Task tapped: \(task.title)")
      showingTaskDetailPopover = true
    }
    .popover(
      isPresented: $showingTaskDetailPopover,
      attachmentAnchor: .point(.trailing),
      arrowEdge: .leading
    ) {
      TaskDetailView(task: task)
        .background(Color(.systemBackground))
        .frame(minWidth: UIScreen.main.bounds.width * 0.45, maxWidth: .infinity)
    }
  }
}

struct MainSheet: ViewModifier {
  @State var bottomSheetPosition: BottomSheetPosition = .dynamicBottom

  @State private var searchText = ""
  @State private var isEditing = false

  func body(content: Content) -> some View {
    content
      .bottomSheet(
        bottomSheetPosition: $bottomSheetPosition,
        switchablePositions: [
          .dynamicBottom,
          .relative(0.95),
        ],
        headerContent: {
          SearchBar("Cari tanaman atau pekerjaan", text: $searchText, isEditing: $isEditing)
            .showsCancelButton(isEditing)
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
      ) {
        MainSheetContentView()
      }
      .commonModifiers()
  }
}

extension BottomSheet {
  func commonModifiers() -> BottomSheet {
    self
      .iPadSheetAlignment(.bottomLeading)
      .enableContentDrag()
      .customBackground {
        VisualEffectBlurView(blurStyle: .systemThinMaterial)
          .cornerRadius(20)
      }
  }
}

extension View {
  func mainSheet() -> some View {
    modifier(MainSheet())
  }
}
