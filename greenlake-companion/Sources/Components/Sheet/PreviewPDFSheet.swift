//
//  PreviewPDFSheet.swift
//  greenlake-companion
//
//  Created by Savio Enoson on 09/09/25.
//

import SwiftUI

enum PDFReportType {
  case taskChecklist
  case overdueBill
  case taskInformation
  case report // Berita acara
}

struct PreviewPDFSheet: View {
  private let sheetMinWidth = min(UIScreen.main.bounds.width - 60, 900)
  @EnvironmentObject private var viewModel: AgendaViewModel
  
  var body: some View {
    VStack {
      HStack {
        Button("Batal") {
          viewModel.pdfPreview = nil
        }
        .foregroundColor(Color(.systemRed))
        
        Spacer()
        
        Text("Preview")
        
        Spacer()
        
        Button("Kirimkan") {
          print("send button")
        }
      }
      .padding(.horizontal)
      .padding(.bottom)
      
      Divider()
      
      HStack(spacing: 0) {
        // --- Left Column ---
        VStack {
          Text("Controls")
            .font(.headline)
            .padding()
          
          List(1..<11) { item in
            Text("Task \(item)")
          }
        }
        .frame(maxWidth: sheetMinWidth * 0.34)
        
        Divider()
        
        // --- Right Column ---
        VStack {
          if let currentPDF = viewModel.pdfPreview {
              // ADD THIS LINE FOR DEBUGGING
              Text("PDF Loaded: \(currentPDF.data.count) bytes")
                  .font(.caption)
                  .foregroundStyle(.secondary)
                  .padding(5)
                  .background(Color.yellow.opacity(0.2))

              PDFKitView(data: currentPDF.data)
          } else {
              EmptyView()
          }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
      }
    }
    .frame(minWidth: sheetMinWidth)
  }
}
