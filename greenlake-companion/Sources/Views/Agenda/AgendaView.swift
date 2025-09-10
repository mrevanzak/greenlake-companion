//
//  AgendaView.swift
//  greenlake-companion
//
//  Created by Savio Enoson on 01/09/25.
//

import SwiftUI

struct AgendaView: View {
  @StateObject private var viewModel = AgendaViewModel()
  @State private var columnVisibility = NavigationSplitViewVisibility.all
    @Environment(\.colorScheme) private var colorScheme
  private var sidebarWidth = max(UIScreen.main.bounds.width * 0.34, 350)
  private let exportButtonHeight = 50.0

  @State private var adjustedHeight = UIScreen.main.bounds.height + adjustY
  @State private var isLandscape: Bool = UIScreen.main.bounds.width > UIScreen.main.bounds.height
  @State private var isContentVisible: Bool = true

  @State private var isFilterPresented = false

  var body: some View {
    GeometryReader { geometry in
      NavigationSplitView(columnVisibility: $columnVisibility) {
        VStack(spacing: 0) {
          VStack(alignment: .leading, spacing: 12) {

            // Search Bar
            HStack(spacing: 10) {
              HStack {
                Image(systemName: "magnifyingglass")
                  .foregroundColor(.secondary)
                TextField("Search Tasks", text: $viewModel.searchText)
                Image(systemName: "microphone.fill")
                  .foregroundColor(.secondary)
              }
              .padding(10)
              .background(isLandscape ? Color(.systemGray6) : Color(.systemGray4))
              .cornerRadius(10)

              Button {
                isFilterPresented = true
              } label: {
                Image(systemName: "line.3.horizontal.decrease")
                  .resizable()
                  .frame(width: 30, height: 30)
                  .foregroundColor(viewModel.filterViewModel.isDefaultState ? .secondary : .blue)
              }
              .popover(
                isPresented: $isFilterPresented,
                attachmentAnchor: .point(.trailing),
                arrowEdge: .leading
              ) {
                FilterPopover(viewModel: viewModel.filterViewModel)
                  .presentationCompactAdaptation(.popover)
              }
            }
            .padding(.horizontal)
          }
          .padding(.vertical)

          ScrollView {
            LazyVStack(spacing: 0) {
              if viewModel.isLoading {
                // Loading state
                VStack(spacing: 16) {
                  ProgressView("Loading tasks...")
                    .font(.headline)
                  Text("Please wait while we fetch your tasks")
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 50)
              } else if let errorMessage = viewModel.errorMessage {
                // Error state
                VStack(spacing: 16) {
                  Image(systemName: "exclamationmark.triangle")
                    .font(.largeTitle)
                    .foregroundColor(.red)
                  Text("Error Loading Tasks")
                    .font(.headline)
                  Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                  Button("Retry") {
                    Task {
                      await viewModel.loadTasks()
                    }
                  }
                  .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 50)
              } else if viewModel.filteredTasks.isEmpty {
                // Empty state
                VStack(spacing: 16) {
                  Image(systemName: "list.bullet")
                    .font(.largeTitle)
                    .foregroundColor(.secondary)
                  Text("No Tasks Found")
                    .font(.headline)
                  Text("No tasks match your current filters")
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 50)
              } else {
                // Tasks list
                ForEach(viewModel.filteredTasks) { task in
                  TaskPreview(task: task)
                    .padding()
                    .background(viewModel.selectedTask == task ? Color.blue : .clear)
                    .foregroundColor(viewModel.selectedTask == task ? Color.white : .primary)
                    .onTapGesture {
                      withAnimation(.easeInOut(duration: 0.3)) {
                        viewModel.selectTask(task)
                      }
                    }

                  Divider()
                }
              }
            }
          }.safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 48)
          }
        }
        .toolbar(.hidden)
        .navigationSplitViewColumnWidth(sidebarWidth)
      } detail: {
        VStack {
          ScrollView {
            if let selectedTask = viewModel.selectedTask {
              TaskDetailView(task: selectedTask)
                .opacity(isContentVisible ? 1 : 0)
                .onChange(of: selectedTask) {
                  withAnimation(.easeOut(duration: 0.2)) {
                    isContentVisible = false
                  }

                  DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.easeIn(duration: 0.2)) {
                      isContentVisible = true
                    }
                  }
                }
            } else {
              EmptyView()
            }
          }
          .navigationSplitViewStyle(.balanced)
          .onAppear {
            viewModel.selectFirstTaskIfNeeded()
          }
        }
        .toolbar(.hidden)
        .padding(.horizontal)
      }
      .frame(height: adjustedHeight, alignment: .top)
      .offset(y: -adjustY)
      .safeAreaInset(edge: .top, spacing: 0) {
          
          ZStack(alignment : .topLeading) {
              AccountButton()
                  .zIndex(1)
                  .padding()
                  .padding(.vertical, 16)
                  .padding(.horizontal, 6)
                 
              
              VStack {
                  HStack(alignment: .center) {
                      let toolbarButtonSize = 30.0
                      if !isLandscape {
                          Button(action: toggleSidebar) {
                              Image(systemName: "sidebar.left")
                                  .resizable()
                                  .scaledToFit()
                                  .frame(width: toolbarButtonSize, height: toolbarButtonSize)
                          }
                      }
                      //              AccountButton()
                      
                      Spacer()
                      
                      ExportButton()
                  }
                  .padding()
                  .padding(.vertical, 16)
                  .padding(.horizontal, 6)

                  Spacer()
                  Divider()
              }
              .frame(maxWidth: .infinity)
              .background(.ultraThinMaterial)
          }
      }
      .onChange(of: geometry.size) {
        isLandscape = isDeviceInLandscape()
        adjustedHeight = UIScreen.main.bounds.height + adjustY
      }
      .onAppear {
        Task {
          await viewModel.loadTasks()
        }
      }
    }
  }

  private struct AgendaToolbar: View {
    var body: some View {

    }
  }

  private func isDeviceInLandscape() -> Bool {
    return UIScreen.main.bounds.width > UIScreen.main.bounds.height
  }

  private func toggleSidebar() {
    withAnimation {
      columnVisibility = (columnVisibility == .all) ? .detailOnly : .all
    }
  }
}

//#Preview {
//  TabView {
//    AgendaView()
//      .tabItem {
//        Label("Tab 1", image: "map")
//      }
//
//    AgendaView()
//      .tabItem {
//        Label("Tab 2", image: "map")
//      }
//  }
//}
