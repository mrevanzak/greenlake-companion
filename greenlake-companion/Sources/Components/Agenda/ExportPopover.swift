//
//  ExportPopover.swift
//  greenlake-companion
//
//  Created by Savio Enoson on 01/09/25.
//

import SwiftUI

enum ExportedReportType: String, CaseIterable, Identifiable {
  case daily = "Harian"
  case monthly = "Bulanan"
  case penalty = "Denda"
  
  var id: String { self.rawValue }
}

struct ExportPopover: View {
  @State private var selectedReportType: ExportedReportType = .daily
  
  var body: some View {
    VStack(alignment: .leading) {
      Text("Jenis Laporan")
        .font(.title3)
        .fontWeight(.bold)
        .padding(.bottom, 10)
      
      Picker("Jenis Laporan", selection: $selectedReportType) {
        // Loop through all cases of the enum to create the segments.
        ForEach(ExportedReportType.allCases) { reportType in
          Text(reportType.rawValue).tag(reportType)
        }
      }
      .pickerStyle(.segmented)
      
      switch selectedReportType {
      case .daily:
          DailyReportView()
      case .monthly:
          MonthlyReportView()
      case .penalty:
          PenaltyReportView()
      }
      
      Spacer()
      Divider()
      
      HStack {
        Spacer()
        
        Button {
          print("Send Button")
        } label: {
          Text("Reset")
            .foregroundColor(.blue)
        }
      }
      
    }
    .frame(width: 300, height: 400)
    .padding()
    .background(.ultraThinMaterial)
  }
  
  struct DailyReportView: View {
      var body: some View {
          Text("View for Daily Reports")
              .padding()
              .frame(maxWidth: .infinity, minHeight: 150)
              .background(.blue.opacity(0.1))
              .cornerRadius(10)
      }
  }

  struct MonthlyReportView: View {
      var body: some View {
          Text("View for Monthly Reports")
              .padding()
              .frame(maxWidth: .infinity, minHeight: 150)
              .background(.green.opacity(0.1))
              .cornerRadius(10)
      }
  }

  struct PenaltyReportView: View {
      var body: some View {
          Text("View for Penalty Reports")
              .padding()
              .frame(maxWidth: .infinity, minHeight: 150)
              .background(.red.opacity(0.1))
              .cornerRadius(10)
      }
  }
}

#Preview {
  ExportPopover()
}
