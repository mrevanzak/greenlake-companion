//
//  App.swift
//  greenlake-companion
//
//  Created by Revanza Kurniawan on 21/08/25.
//

import SwiftUI

@main
struct GreenlakeCompanionApp: App {
  @StateObject private var authManager = AuthManager.shared
  @StateObject private var plantManager = PlantManager.shared

  var showingPlantDetail: Binding<Bool> {
    Binding(
      get: { plantManager.hasSelectedPlant },
      set: { _ in plantManager.selectPlant(nil) }
    )
  }

  var body: some Scene {
    WindowGroup {
      TabView {
        MapView()
          .ignoresSafeArea(.container, edges: .top)
          .tabItem {
            Label("Peta", image: "map")
          }

        AgendaView()
          .ignoresSafeArea(.container, edges: .top)
          .tabItem {
            Label("Agenda", image: "book.closed")
          }
      }
      .mainSheet()
      .plantDetailSheet(isPresented: showingPlantDetail)
      .plantFormSheet(isPresented: $plantManager.isCreatingPlant)
      .fullScreenCover(isPresented: .constant(!authManager.isAuthenticated)) {
        LoginView()
      }
      .onAppear {
        // Load user data when app starts
        authManager.loadUserFromStorage()
      }
    }.environmentObject(authManager)
  }
}
