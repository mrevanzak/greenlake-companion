//
//  SheetContentViews.swift
//  greenlake-companion
//
//  Created by Revan on 26/08/25.
//

import CoreLocation
import MapKit
import SwiftUI
import SwiftUIX

struct BottomSheetContent: View {
  @EnvironmentObject private var sheetViewModel: SheetViewModel
  @State private var searchText = ""
  @State private var showingPlantConditionSheet = false

  var body: some View {
    ScrollView(showsIndicators: false) {
      LazyVStack(alignment: .leading, spacing: 16, pinnedViews: .sectionHeaders) {
        Section(
          header:
            SearchBar("Cari tanaman atau pekerjaan", text: $searchText)
            .textFieldBackgroundColor(.systemGray6)
            .background(.thickMaterial)
            .cornerRadius(12)
        ) {
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

          Text("Informasi Tanaman")
            .font(.headline)
            .foregroundStyle(.secondary)

          RoundedRectangle(cornerRadius: 18)
            .fill(
              LinearGradient(
                colors: [Color.gray.opacity(0.25), Color.gray.opacity(0.15)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing)
            )
            .frame(height: 220)
            .overlay(
              Image(systemName: "photo").font(.system(size: 40)).foregroundStyle(.secondary))

          // Plant information section
          VStack(alignment: .leading, spacing: 6) {
            Label("Jl. Citra Utama Lidah Kulon", systemImage: "mappin.and.ellipse")
              .font(.subheadline)
              .foregroundStyle(.primary)

            Text("Pine Tree").font(.largeTitle).bold()
            Text("Pinus merkusii").font(.title3).italic().foregroundStyle(.secondary)
          }

          // Action button
          Button(action: {
            showingPlantConditionSheet = true
          }) {
            Text("Catat Kondisi")
              .font(.headline)
              .foregroundStyle(.white)
              .frame(maxWidth: .infinity)
              .padding(.vertical, 14)
          }
          .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 16))
          .padding(.top, 8)

          // Add more content to demonstrate scrolling
          VStack(alignment: .leading, spacing: 12) {
            Text("Riwayat Perawatan")
              .font(.headline)
              .foregroundStyle(.secondary)
              .padding(.top, 16)

            ForEach(historyItems, id: \.title) { item in
              HStack {
                VStack(alignment: .leading, spacing: 4) {
                  Text(item.title)
                    .font(.subheadline.weight(.medium))
                  Text(item.date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                  .font(.caption)
                  .foregroundStyle(.secondary)
              }
              .padding(12)
              .background(Color.gray.opacity(0.05), in: RoundedRectangle(cornerRadius: 12))
            }
          }

          // Additional content to ensure scrolling is needed
          VStack(alignment: .leading, spacing: 12) {
            Text("Catatan Tambahan")
              .font(.headline)
              .foregroundStyle(.secondary)
              .padding(.top, 16)

            Text(
              "Tanaman ini memerlukan perawatan rutin setiap 2 minggu. Perhatikan kondisi tanah dan pastikan drainase yang baik."
            )
            .font(.body)
            .foregroundStyle(.secondary)
            .padding(12)
            .background(Color.blue.opacity(0.05), in: RoundedRectangle(cornerRadius: 12))
          }

          // Ensure there's enough bottom padding for scrolling
          Spacer(minLength: 120)
        }
      }
    }
    .scrollDisabled(sheetViewModel.isSmallest)
    .frame(maxHeight: .infinity)
    .sheet(isPresented: $showingPlantConditionSheet) {
      PlantConditionSheet()
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
