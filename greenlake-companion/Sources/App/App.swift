//
//  App.swift
//  greenlake-companion
//
//  Created by Revanza Kurniawan on 21/08/25.
//

import SwiftUI

@main
struct GreenlakeCompanionApp: App {
  @State private var selectedTabIndex = 0

  @StateObject private var authManager = AuthManager.shared
  @StateObject private var plantManager = PlantManager.shared

  var showingPlantDetail: Binding<Bool> {
    Binding(
      get: { plantManager.hasSelectedPlant && selectedTabIndex == 0 },
      set: { _ in plantManager.selectPlant(nil) }
    )
  }

  var showingPlantForm: Binding<Bool> {
    Binding(
      get: { plantManager.isCreatingPlant && selectedTabIndex == 0 },
      set: { _ in }
    )
  }

  var body: some Scene {
    WindowGroup {
      TabView(selection: $selectedTabIndex) {
        MapView()
          .ignoresSafeArea(.container, edges: .top)
          .tabItem {
            Label("Peta", image: "map")
          }
          .tag(0)

        AgendaView()
          .ignoresSafeArea(.container, edges: .top)
          .tabItem {
            Label("Agenda", image: "book.closed")
          }
          .tag(1)
      }
      .plantDetailSheet(isPresented: showingPlantDetail)
      .plantFormSheet(isPresented: showingPlantForm)
      .fullScreenCover(isPresented: .constant(!authManager.isAuthenticated)) {
        LoginView()
      }
      .onAppear {
        // Load user data when app starts
        authManager.loadUserFromStorage()
      }
    }.environmentObject(authManager)
          .environmentObject(TabSelectionManager(selectedTabIndex: $selectedTabIndex))

  }
}

class TabSelectionManager: ObservableObject {
    @Binding var selectedTabIndex: Int
    
    init(selectedTabIndex: Binding<Int>) {
        self._selectedTabIndex = selectedTabIndex
    }
    
    var isOnMapTab: Bool {
        selectedTabIndex == 0
    }
}
