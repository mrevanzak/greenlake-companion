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
  var body: some View {
    VStack(spacing: 12) {
      HStack {
        Text("Pruning").font(.title3.weight(.semibold))
        Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.red)
        Spacer()
        Image(systemName: "chevron.down").foregroundStyle(.secondary)
      }
      .padding(16)
      .background(Color.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))

      HStack {
        Text("Tanaman Sakit").font(.title3.weight(.semibold))
        Image(systemName: "triangle.fill").foregroundStyle(.orange)
        Spacer()
        Image(systemName: "chevron.down").foregroundStyle(.secondary)
      }
      .padding(16)
      .background(Color.orange.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
    }
    .padding(.horizontal)
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
