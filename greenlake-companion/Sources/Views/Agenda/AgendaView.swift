//
//  AgendaView.swift
//  greenlake-companion
//
//  Created by Savio Enoson on 01/09/25.
//


import SwiftUI

struct AgendaView: View {
  @State private var columnVisibility = NavigationSplitViewVisibility.all
  private var sidebarWidth = max(UIScreen.main.bounds.width * 0.34, 350)
  private let exportButtonHeight = 50.0
  
  @State private var adjustedHeight = UIScreen.main.bounds.height + adjustY
  @State private var isLandscape: Bool = UIScreen.main.bounds.width > UIScreen.main.bounds.height
  @State private var isContentVisible: Bool = true
  
  @StateObject private var filterViewModel = FilterViewModel()
  
  @State private var searchText = ""
  @State private var isFilterPresented = false
  
  @State private var selectedTask: LandscapingTask?
  var filteredTasks: [LandscapingTask] {
    // 1. Start with the full list of tasks.
    var processedTasks = sampleTasks
    
    // 2. Apply all enum-based filters from the ViewModel.
    processedTasks = processedTasks.filter { task in
      let typeMatch = filterViewModel.taskType.isEmpty || filterViewModel.taskType.contains(task.taskType)
      let urgencyMatch = filterViewModel.urgency.isEmpty || filterViewModel.urgency.contains(task.urgencyLabel)
      let plantMatch = filterViewModel.plantType.isEmpty || filterViewModel.plantType.contains(task.plantType)
      let statusMatch = filterViewModel.status.isEmpty || filterViewModel.status.contains(task.status)
      
      return typeMatch && urgencyMatch && plantMatch && statusMatch
    }
    
    // 3. Apply the date range filter if the date range is valid AND not the default.
    let isDefaultDateRange = Calendar.current.isDate(filterViewModel.startDate, inSameDayAs: filterViewModel.endDate)
    
    if filterViewModel.startDate <= filterViewModel.endDate && !isDefaultDateRange {
      
      // To include the entire end date, we calculate the start of the *next* day.
      let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: filterViewModel.endDate)) ?? filterViewModel.endDate
      let startOfDay = Calendar.current.startOfDay(for: filterViewModel.startDate)
      
      processedTasks = processedTasks.filter { task in
        return task.dateCreated >= startOfDay && task.dateCreated < endOfDay
      }
    }
    
    // 4. Apply the search text filter to the already-filtered list.
    if !searchText.isEmpty {
      processedTasks = processedTasks.filter { task in
        task.title.localizedCaseInsensitiveContains(searchText) ||
        task.description.localizedCaseInsensitiveContains(searchText)
      }
    }
    
    // 5. Apply sorting as the final step.
    // (Assuming you have SortKey cases like .dateCreated and .title)
    switch filterViewModel.sortKey {
    case .dateCreated:
      processedTasks.sort {
        if filterViewModel.sortOrder == .ascending {
          return $0.dateCreated < $1.dateCreated
        } else {
          return $0.dateCreated > $1.dateCreated
        }
      }
      
    case .dateModified, .dateClosed:
      processedTasks.sort { lhs, rhs in
        // Determine which optional date property to use based on the sort key
        let lhsDate = (filterViewModel.sortKey == .dateModified) ? lhs.dateModified : lhs.dateClosed
        let rhsDate = (filterViewModel.sortKey == .dateModified) ? rhs.dateModified : rhs.dateClosed
        
        let isAscending = filterViewModel.sortOrder == .ascending
        
        switch (lhsDate, rhsDate) {
          // Case 1: Both tasks have a valid date. Compare them normally.
        case let (l?, r?):
          return isAscending ? l < r : l > r
          
          // Case 2: Only the left task has a date, so it comes first.
        case (_?, nil):
          return true
          
          // Case 3: Only the right task has a date, so it comes first.
        case (nil, _?):
          return false
          
          // Case 4: Both are nil, so their order doesn't matter.
        case (nil, nil):
          return false
        }
      }
    }
    
    // 6. Return the final, processed list.
    return processedTasks
  }
  
  var body: some View {
    GeometryReader { geometry in
      NavigationSplitView(columnVisibility: $columnVisibility) {
        VStack(spacing: 0) {
          VStack(alignment: .leading, spacing: 12) {
//            Text("Agenda")
//              .font(.largeTitle)
//              .fontWeight(.bold)
//              .padding(.horizontal)
            
            // Search Bar
            HStack(spacing: 10) {
              HStack {
                Image(systemName: "magnifyingglass")
                  .foregroundColor(.secondary)
                TextField("Search Tasks", text: $searchText)
                Image(systemName: "microphone.fill")
                  .foregroundColor(.secondary)
              }
              .padding(10)
              .background(isLandscape ? Color.systemGray6 : Color.systemGray4)
              .cornerRadius(10)
              
              Button {
                isFilterPresented = true
              } label: {
                Image(systemName: "line.3.horizontal.decrease.circle")
                  .resizable()
                  .frame(width: 30, height: 30)
                  .foregroundColor(filterViewModel.isDefaultState ? .secondary : .blue)
              }
              .popover(
                isPresented: $isFilterPresented,
                attachmentAnchor: .point(.trailing),
                arrowEdge: .leading
              ) {
                FilterPopover(viewModel: filterViewModel)
                  .presentationCompactAdaptation(.popover)
              }
            }
            .padding(.horizontal)
          }
          .padding(.vertical)
          
          ScrollView {
            LazyVStack(spacing: 0) {
              ForEach(filteredTasks) { task in
                TaskPreview(task: task)
                  .padding()
                  .background(selectedTask == task ? Color.blue : .clear)
                  .foregroundColor(selectedTask == task ? Color.white : .primary)
                  .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                      selectedTask = task
                    }
                  }
                
                Divider()
              }
            }
          }
        }
        .toolbar(.hidden)
        .navigationSplitViewColumnWidth(sidebarWidth)
      }
      detail: {
        VStack {
          ScrollView {
            if let selectedTask {
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
            selectedTask = filteredTasks[0]
          }
        }
        .toolbar(.hidden)
        .padding(.horizontal)
      }
      .frame(height: adjustedHeight, alignment: .top)
      .offset(y: -adjustY)
      .safeAreaInset(edge: .top, spacing: 0) {
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
            
            Spacer()
            
            Menu {
              Button {
                print("Checklist")
              } label: {
                Label("Checklist", systemImage: "checklist")
              }
              
              Button {
                print("Denda")
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
      }
      .onChange(of: geometry.size) {
        isLandscape = isDeviceInLandscape()
        adjustedHeight = UIScreen.main.bounds.height + adjustY
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

#Preview {
  TabView {
    AgendaView()
      .tabItem{
        Label("Tab 1", image: "map")
      }
    
    AgendaView()
      .tabItem{
        Label("Tab 2", image: "map")
      }
  }
}
