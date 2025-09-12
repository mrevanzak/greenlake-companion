//
//  AgendaViewToolbar.swift
//  greenlake-companion
//
//  Created by Savio Enoson on 09/09/25.
//

import Foundation
import SwiftUI

struct AgendaViewToolbar: View {
  @StateObject private var viewModel = AgendaViewModel.shared

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

        ExportButton(
          checklistAction: {
            Task {
              //            viewModel.pdfPreview = try await generateTaskChecklistPDF(tasksToDraw: viewModel.getHeader())
              viewModel.requestedExportType = .checklist
            }
          },
          dendaAction: {
            Task {
              //            viewModel.pdfPreview = await generateFinePDF(tasksToDraw: viewModel.getHeader())
              viewModel.requestedExportType = .fine
            }
          }
        )
        .opacity(1)
      }
      .padding()
      .padding(.top)
      .padding(.horizontal)
    }
    .frame(maxWidth: .infinity)
    .background(.ultraThinMaterial)

    .sheet(item: $viewModel.requestedExportType) { _ in
      PreviewPDFSheet()
        .background(.ultraThinMaterial)
    }.presentationDetents([.large])

  }

  private func toggleSidebar() {
    withAnimation {
      columnVisibility =
        (columnVisibility == NavigationSplitViewVisibility.all)
        ? NavigationSplitViewVisibility.detailOnly : NavigationSplitViewVisibility.all
    }
  }
}
