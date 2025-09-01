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

  var body: some Scene {
    WindowGroup {
      TabView {
        MapView()
          .tabItem{
              Label("Peta", image: "map")
          }
        
        AgendaView()
          .tabItem{
            Label("Agenda", image: "book.closed")
          }
      }
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
