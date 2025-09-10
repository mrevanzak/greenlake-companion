//
//  AgendaViewToolbar.swift
//  greenlake-companion
//
//  Created by Savio Enoson on 09/09/25.
//

import SwiftUI
import Foundation

struct AgendaViewToolbar: View {
  @EnvironmentObject private var viewModel: AgendaViewModel
  @EnvironmentObject private var authManager: AuthManager
  var adminUsername: String {
    return authManager.currentUser?.name ?? "Admin"
  }
  
  @Binding var isLandscape: Bool
  @Binding var columnVisibility: NavigationSplitViewVisibility
  
  private let toolbarButtonSize = 30.0
  
  var body: some View {
    VStack {
      HStack(alignment: .center) {
        if !isLandscape {
          Button(action: toggleSidebar) {
            Image(systemName: "sidebar.left")
              .resizable()
              .scaledToFit()
              .frame(width: toolbarButtonSize, height: toolbarButtonSize)
          }
        }
        
        Spacer()
        
        // Export Menu
        Menu {
          Button {
            Task {
              viewModel.pdfPreview = await generateTaskChecklistPDF(tasksToDraw: viewModel.getHeader())
            }
          } label: {
            Label("Checklist", systemImage: "checklist")
          }
          
          Button {
            Task {
              viewModel.pdfPreview = await generateFinePDF(tasksToDraw: viewModel.getHeader())
            }
          } label: {
            Label("Denda", systemImage: "dollarsign")
          }
        } label: {
          Image(systemName: "square.and.arrow.up")
            .resizable()
            .scaledToFit()
            .frame(width: toolbarButtonSize, height: toolbarButtonSize)
        }
        .foregroundColor(.accentColor)
      }
      .padding()
      .padding(.top)
      .padding(.horizontal)
      
      Spacer()
      
      Divider()
    }
    .frame(maxWidth: .infinity)
    .background(.ultraThinMaterial)
    
    .sheet(item: $viewModel.pdfPreview) { _ in
        PreviewPDFSheet()
    }.presentationDetents([.large])

  }
  
  private func toggleSidebar() {
    withAnimation {
      columnVisibility = (columnVisibility == NavigationSplitViewVisibility.all) ? NavigationSplitViewVisibility.detailOnly : NavigationSplitViewVisibility.all
    }
  }
 
  private func generateTaskChecklistPDF(tasksToDraw: [LandscapingTask]) async -> PDFDataWrapper {
    let pdfBuilder = PDFBuilder()
    let reportTitle = "REKAPITULASI PEKERJAAN"
    let pdfData = pdfBuilder.createPDF { pdf in
      pdf.drawHeader(title: reportTitle, sender: adminUsername, date: Date())
      pdf.drawTasks(tasks: tasksToDraw)
    }
    return PDFDataWrapper(data: pdfData)
  }
  
  private func generateFinePDF(tasksToDraw: [LandscapingTask]) async -> PDFDataWrapper {
    let pdfBuilder = PDFBuilder()
    let reportTitle = "LAPORAN KETERLAMBATAN"
    let pdfData = pdfBuilder.createPDF { pdf in
      pdf.drawHeader(title: reportTitle, sender: adminUsername, date: Date())
      pdf.drawFineTable(finedTasks: tasksToDraw)
    }
    return PDFDataWrapper(data: pdfData)
  }
}
