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
    ZStack {
      VStack {
        Spacer()
        Divider()
      }
      
      // Sidebar Toggle
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
      }
      .padding()
      .padding(.top)
      .padding(.horizontal)
      
      // Export Menu
      HStack(alignment: .center) {
        Spacer()
        
        ExportButton(checklistAction: {
          Task {
            viewModel.pdfPreview = try await generateTaskChecklistPDF(tasksToDraw: viewModel.getHeader())
          }
        }, dendaAction: {
          Task {
            viewModel.pdfPreview = await generateFinePDF(tasksToDraw: viewModel.getHeader())  // TODO: Filter for only late tasks.
          }
        })
        .opacity(1)
      }
      .padding()
      .padding(.top)
      .padding(.horizontal)
    }
    .frame(maxWidth: .infinity)
    .background(.ultraThinMaterial)
    
    .sheet(item: $viewModel.pdfPreview) { _ in
        PreviewPDFSheet()
        .background(.ultraThinMaterial)
    }.presentationDetents([.large])

  }
  
  private func toggleSidebar() {
    withAnimation {
      columnVisibility = (columnVisibility == NavigationSplitViewVisibility.all) ? NavigationSplitViewVisibility.detailOnly : NavigationSplitViewVisibility.all
    }
  }
 
  private func generateTaskChecklistPDF(tasksToDraw: [LandscapingTask]) async throws -> PDFDataWrapper {
    let pdfBuilder = PDFBuilder()
    let taskService = TaskService()
    let reportTitle = "REKAPITULASI PEKERJAAN"
    do {
      let imagesDictionary = try await taskService.fetchImages(for: tasksToDraw)
      
      let pdfData = pdfBuilder.createPDF { pdf in
        pdf.drawHeader(title: reportTitle, sender: adminUsername, date: Date())
        pdf.drawTasks(tasks: tasksToDraw, images: imagesDictionary)
      }
      return PDFDataWrapper(data: pdfData)
      
    } catch {
      throw PDFGenerationError.invalidImageData
    }
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
