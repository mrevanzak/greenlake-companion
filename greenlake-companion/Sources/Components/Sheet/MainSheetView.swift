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

enum BottomSheetScreen {
  case main
  case plantDetail
}

//MARK: - Sheet Content

struct MainSheetContentView: View {
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
  private struct ActiveTask {
    let title: String
    let location: String
    let priority: String
    let date: String
    let backgroundColor: Color
  }

  private var activeTasks: [ActiveTask] {
    [
      .init(
        title: "Pruning",
        location: "C05-11",
        priority: "Urgent",
        date: "20 Agustus 2025",
        backgroundColor: Color(hue: 0.0, saturation: 0.9, brightness: 1.0, opacity: 1)
      ),
      .init(
        title: "Tanaman Sakit",
        location: "C05-13",
        priority: "Warning",
        date: "12 Agustus 2025",
        backgroundColor: Color(hue: 0.085, saturation: 0.9, brightness: 1.0, opacity: 1)
      ),
    ]
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 40) {
      VStack(alignment: .leading) {
        Text("Informasi Landscape")
          .font(.system(size: 16, weight: .semibold))
          .italic()
          .foregroundColor(.secondary)

        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
          ForEach(Array(landscapeData.enumerated()), id: \.offset) { index, info in
            VStack(alignment: .leading, spacing: 0) {
              Text(info.title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.black)
                .padding(0)
              Text(info.value)
                .font(.system(size: 45, weight: .black))
                .fontWidth(.compressed)
                .foregroundColor(Color(hue: 0.09, saturation: 0, brightness: 0.2, opacity: 1))
                .padding(0)
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
        }
      }

      VStack(alignment: .leading) {
        Text("Pekerjaan Aktif")
          .font(.system(size: 16, weight: .semibold))
          .italic()
          .foregroundColor(.secondary)

        ForEach(Array(activeTasks.enumerated()), id: \.offset) { index, task in
          HStack {
            VStack(alignment: .leading) {
              Text(task.title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)

              Text(task.location)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
            }
            Spacer()

            VStack(alignment: .trailing) {
              Text(task.priority)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
              Text(task.date)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
            }
          }
          .padding(.vertical, 12)
          .padding(.horizontal, 18)
          .background(task.backgroundColor, in: RoundedRectangle(cornerRadius: 20))
          .overlay(
            RoundedRectangle(cornerRadius: 20)
              .strokeBorder(Color.white.opacity(0.3), lineWidth: 1)
          )
          .shadow(color: .black.opacity(0.2), radius: 16, x: 10, y: 10)
        }
      }
    }
  }

  private struct HistoryItem {
    let title: String
    let date: String
  }
  private var historyItems: [HistoryItem] {
    [
      .init(title: "Pruning", date: "20 Agustus 2025"),
      .init(title: "Perawatan rutin", date: "14 Agustus 2025"),
      .init(title: "Pruning", date: "10 Juli 2025"),
      .init(title: "Pruning", date: "15 Juni 2025"),
    ]
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
          .absolute(325),
        ],
        headerContent: {
          SearchBar("Cari tanaman atau pekerjaan", text: $searchText, isEditing: $isEditing)
            .showsCancelButton(isEditing)
            .padding(.horizontal, 8)
        }
      ) {
        MainSheetContentView()
      }
      .backgroundBlurMaterial(.adaptive(.thin))
      .enableFloatingIPadSheet(false)
      .iPadSheetAlignment(.bottomLeading)
      .sheetSidePadding(24)
      .enableContentDrag()
  }
}

extension View {
  func mainSheet() -> some View {
    modifier(MainSheet())
  }
}
