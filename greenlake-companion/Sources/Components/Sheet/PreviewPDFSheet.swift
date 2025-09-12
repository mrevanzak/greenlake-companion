//
//  PreviewPDFSheet.swift
//  greenlake-companion
//
//  Created by Savio Enoson on 09/09/25.
//

import SwiftUI

//enum PDFReportType {
//  case taskChecklist
//  case overdueBill
//  case taskInformation
//  case report // Berita acara
//}

struct PreviewPDFSheet: View {
  private let sheetMinWidth = max(UIScreen.main.bounds.width - 60, 450)
  
  @StateObject private var viewModel = AgendaViewModel.shared
  
  var body: some View {
    VStack(spacing: 0) {
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
      .padding()
      
      Divider()
      
      HStack(spacing: 0) {
        // --- Left Column ---
        VStack {
          Text("Controls")
            .font(.headline)
            .padding(.top)
          
          List(1..<11) { item in
            Text("Task \(item)")
          }
          .background(.clear)
        }
        .frame(maxWidth: sheetMinWidth * 0.34)
        .background(.clear)

        // --- Right Column ---
        VStack {
          if let currentPDF = viewModel.pdfPreview {
              PDFKitView(data: currentPDF.data)
          } else {
              EmptyView()
          }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.secondary)
      }
    }
    .frame(minWidth: sheetMinWidth)
  }
}
