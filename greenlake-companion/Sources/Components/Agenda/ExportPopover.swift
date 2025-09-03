//
//  ExportPopover.swift
//  greenlake-companion
//
//  Created by Savio Enoson on 01/09/25.
//

import SwiftUI

enum ExportedReportType: String, CaseIterable, Identifiable {
  case daily = "Checklist"
  case monthly = "Bulanan"
  case penalty = "Denda"

  var id: String { self.rawValue }
}

struct ExportPopover: View {
  @State private var reportType: ExportedReportType = .daily
  @State private var useDateRange: Bool = false
  @State private var startDate: Date = Date()
  @State private var endDate: Date = Date()

  var body: some View {
    VStack {
      VStack(alignment: .leading, spacing: 20) {
        Text(reportType.rawValue)
          .font(.title3)
          .fontWeight(.bold)

        Picker(reportType.rawValue, selection: $reportType) {
          ForEach(ExportedReportType.allCases) { reportType in
            Text(reportType.rawValue).tag(reportType)
          }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, 0)

        Toggle(
          "Filter Tanggal",
          isOn: $useDateRange
        )
      }
      .padding()

      if useDateRange {
        Spacer()

        VStack(alignment: .leading, spacing: 10) {
          Text("Pilih Tanggal")
            .font(.subheadline.weight(.bold))

          DatePicker(
            "Mulai",
            selection: $startDate,
            displayedComponents: .date
          )

          DatePicker(
            "Hingga",
            selection: $endDate,
            displayedComponents: .date
          )

          Spacer()
        }
        .padding()
        .frame(height: useDateRange ? 100 : 0)
        .animation(.spring(duration: 0.5))
      }

      Divider()

      HStack {
        Spacer()

        Button {
          print("Send Button")
        } label: {
          Text("Buat Laporan")
            .foregroundColor(.blue)
        }
      }
      .frame(height: 40)
      .padding(.trailing)
    }
    .background(.ultraThinMaterial)
    .frame(width: 300)
    .animation(.spring(duration: 0.5))
  }
}

#Preview {
  ExportPopover()
    .presentationCompactAdaptation(.popover)

}
