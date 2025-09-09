//
//  SheetContentViews.swift
//  greenlake-companion
//
//  Created by Revan on 26/08/25.
//

import CoreLocation
import MapKit
import SwiftUI

enum BottomSheetScreen {
  case main
  case plantDetail
}

//MARK: - Sheet Content

struct MainSheetView: View {
  @EnvironmentObject private var sheetViewModel: SheetViewModel

  @State private var searchText = ""

  @StateObject var router = Router.shared
  @StateObject private var plantManager = PlantManager.shared

  private func onPlantChangeHandler(oldValue: PlantInstance?, newValue: PlantInstance?) {
    if newValue != nil {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
        sheetViewModel.updateCurrentDetent(.large)
      }
    }
  }

  private func cleanup() {
    plantManager.selectPlant(nil)
    plantManager.stopPathDrawing()
    plantManager.discardTemporaryPlant()
  }

  var body: some View {
    NavigationStack(path: $router.path) {
      ScrollView(showsIndicators: false) {
        VStack(alignment: .leading) {
          Section {
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
          }
        }
        .padding(.horizontal)
      }
      .searchable(
        text: $searchText, placement: .navigationBarDrawer(displayMode: .always),
        prompt: "Cari tanaman atau pekerjaan"
      )
      .scrollDisabled(sheetViewModel.isSmallest)
      .frame(maxHeight: .infinity)
      .onChange(of: plantManager.selectedPlant) {
        onPlantChangeHandler(oldValue: $0, newValue: $1)
      }
      .onChange(of: plantManager.temporaryPlant) {
        onPlantChangeHandler(oldValue: $0, newValue: $1)
      }
      .navigationBarTitle("Halaman Utama", displayMode: .inline)
      .navigationDestination(item: $plantManager.temporaryPlant) { plant in
        PlantFormView(mode: .create)
          .onDisappear(perform: cleanup)
      }
      .navigationDestination(item: $plantManager.selectedPlant) { plant in
        PlantDetailView()
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


