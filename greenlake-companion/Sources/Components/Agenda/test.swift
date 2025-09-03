//
//  test.swift
//  greenlake-companion
//
//  Created by Savio Enoson on 03/09/25.
//

import SwiftUI

/// A view that demonstrates a full-width toolbar above a NavigationSplitView.
///
/// The `.safeAreaInset` modifier is used to place a custom toolbar view
/// at the top of the screen. This ensures the toolbar spans the entire width,
/// regardless of the device or the split view's column layout, which is a
/// common requirement for creating a consistent top-level navigation bar.
struct TestHalo: View {
    // State to manage the visibility of the split view's columns.
    @State private var columnVisibility = NavigationSplitViewVisibility.all
    
    // State to track the selected category in the sidebar.
    @State private var selectedCategory: Category? = .inbox
    
    // State to track the selected item in the content list.
    @State private var selectedItem: Item?

    /// Represents the categories in the sidebar.
    enum Category: String, CaseIterable, Hashable {
        case inbox = "Inbox"
        case sent = "Sent"
        case drafts = "Drafts"
        case trash = "Trash"
        
        var systemImage: String {
            switch self {
            case .inbox: "tray.fill"
            case .sent: "paperplane.fill"
            case .drafts: "doc.fill"
            case .trash: "trash.fill"
            }
        }
    }
    
    /// Represents a sample item within a category.
    struct Item: Identifiable, Hashable {
        let id = UUID()
        let title: String
    }
    
    // Sample data for the content list based on the selected category.
    let itemsByCategory: [Category: [Item]] = [
        .inbox: (1...20).map { Item(title: "Inbox Message \($0)") },
        .sent: (1...10).map { Item(title: "Sent Mail \($0)") },
        .drafts: (1...5).map { Item(title: "Draft \($0)") },
        .trash: []
    ]

    var body: some View {
        // NavigationSplitView is the main component for our three-column layout.
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // --- Sidebar View ---
            List(Category.allCases, id: \.self, selection: $selectedCategory) { category in
                Label(category.rawValue, systemImage: category.systemImage)
            }
            .navigationTitle("Mailboxes")
            .toolbar(.hidden)
        } detail: {
          ScrollView {
            // --- Detail View ---
            if let item = selectedItem {
                Text("Details for \(item.title)")
                    .navigationTitle(item.title)
            } else {
                Text("Select a message to view its details.")
            }
          
          Text("test\n\n\n")
          Text("test\n\n\n")
          Text("test\n\n\n")
          Text("test\n\n\n")
          Text("test\n\n\n")
          Text("test\n\n\n")
          Text("test\n\n\n")
          Text("test\n\n\n")
          Text("test\n\n\n")
          Text("test\n\n\n")
          Text("test\n\n\n")
          Text("test\n\n\n")
          Text("test\n\n\n")
          Text("test\n\n\n")
          Text("test\n\n\n")
          Text("test\n\n\n")
          Text("test\n\n\n")
          Text("test\n\n\n")
          Text("test\n\n\n")
          Text("test\n\n\n")
          Text("test\n\n\n")
          Text("test\n\n\n")
          Text("test\n\n\n")
          Text("test\n\n\n")
          Text("test\n\n\n")
          Text("test\n\n\n")
          Text("test\n\n\n")
          }
          .toolbar(.hidden)
        }
        // This is the key modifier for achieving the full-width toolbar.
        // It insets the NavigationSplitView from the top and places our
        // custom toolbar view in that space.
        .safeAreaInset(edge: .top, spacing: 0) {
            customToolbar
        }
    }
    
    /// A custom view that acts as a full-width top toolbar.
    private var customToolbar: some View {
        HStack {
            // Button to toggle the sidebar's visibility.
            Button(action: toggleSidebar) {
                Image(systemName: "sidebar.left")
            }
            .help("Toggle Sidebar")

            Spacer()

            Text("My Mail App")
                .font(.headline)
                .fontWeight(.semibold)

            Spacer()

            Button(action: {
                // Placeholder action for adding a new item.
                print("Add new item tapped.")
            }) {
                Image(systemName: "plus")
            }
            .help("New Message")
        }
        .padding()
        .frame(maxWidth: .infinity)
        // Use the .bar material for a standard, translucent toolbar appearance.
        .background(.bar)
    }
    
    /// Toggles the visibility of the sidebar.
    private func toggleSidebar() {
        withAnimation {
            columnVisibility = (columnVisibility == .all) ? .detailOnly : .all
        }
    }
}

#Preview {
  TabView {
    TestHalo()
      .tabItem{
          Label("test", image: "map")
      }
      .ignoresSafeArea()
    
    TestHalo()
      .tabItem{
          Label("Peta", image: "map")
      }
  }
  .ignoresSafeArea()
}
