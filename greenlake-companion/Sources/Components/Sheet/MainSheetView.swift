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
          .font(.system(size: 12, weight: .semibold))
          .italic()
          .foregroundColor(.secondary)

        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
          buildCard(title: "Pohon\n", value: plantManager.getCount(for: "tree"))
          buildCard(title: "Semak\n", value: plantManager.getCount(for: "bush"))
          buildCard(title: "Ground Cover", value: plantManager.getCount(for: "ground_cover"))
//          buildCard(title: "Total Tanaman", value: plantManager.totalPlantCount)
        }
      }

      VStack(alignment: .leading) {
        Text("Informasi Pekerjaan")
          .font(.system(size: 16, weight: .semibold))
          .italic()
          .foregroundColor(.secondary)

        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
          buildCard(title: "Aktif", value: "\(viewModel.taskSummary?.activeTask ?? 0)")
          buildCard(title: "Diajukan", value: "\(viewModel.taskSummary?.diajukanTask ?? 0)")
          buildCard(title: "Diperiksa", value: "\(viewModel.taskSummary?.diperiksaTask ?? 0)")
          buildCard(
            title: "Urgent", value: "\(viewModel.taskSummary?.approachingDeadline ?? 0)"
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

//  var background: Color {
//    switch task.status {
//    case .diperiksa:
//      return .customOrange
//    case .diajukan:
//      return .customRed
//    default:
//      return .customGreen
//    }
//  }

  var body: some View {
    HStack {
      VStack(alignment: .leading) {
        Text(task.title)
          .font(.system(size: 16, weight: .medium))
          .foregroundColor(.black)

        Text(task.status.displayName)
          .font(.system(size: 16, weight: .medium))
          .foregroundColor(.black)
      }
      Spacer()
    }
    .padding(.vertical, 12)
    .padding(.horizontal, 18)
//    .background(background, in: RoundedRectangle(cornerRadius: 20))
    .background(Color.white, in: RoundedRectangle(cornerRadius: 20))
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
//        .background(Color(.systemBackground))
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
      .enableAppleScrollBehavior()
  }
}

extension BottomSheet {
  func commonModifiers() -> BottomSheet {
    self
//      .enableAppleScrollBehavior()
      .iPadSheetAlignment(.bottomLeading)
//      .enableContentDrag()
      .customBackground {
        VisualEffectBlurView(blurStyle: .systemThinMaterial)
          .cornerRadius(20)
      }
  }
}

extension Color {
  init(hex: String) {
    let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    var int: UInt64 = 0
    Scanner(string: hex).scanHexInt64(&int)
    
    let a, r, g, b: UInt64
    switch hex.count {
    case 3:
      (a, r, g, b) = (255,
                      (int >> 8) * 17,
                      (int >> 4 & 0xF) * 17,
                      (int & 0xF) * 17)
    case 6:
      (a, r, g, b) = (255,
                      int >> 16,
                      int >> 8 & 0xFF,
                      int & 0xFF)
    case 8:
      (a, r, g, b) = (int >> 24,
                      int >> 16 & 0xFF,
                      int >> 8 & 0xFF,
                      int & 0xFF)
    default:
      (a, r, g, b) = (255, 0, 0, 0)
    }
    
    self.init(.sRGB,
              red: Double(r) / 255,
              green: Double(g) / 255,
              blue: Double(b) / 255,
              opacity: Double(a) / 255)
  }
  
  static let customGreen = Color(hex: "#4CAF50")
  static let customRed = Color(hex: "#FF5252")
  static let customOrange = Color(hex: "#E69229")
}


extension View {
  func mainSheet() -> some View {
    modifier(MainSheet())
  }
}

#Preview {
  Color.clear.mainSheet()
}
