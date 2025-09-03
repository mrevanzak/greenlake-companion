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
    @StateObject private var taskManager = TaskManager.shared
    
    var body: some Scene {
        WindowGroup {
            TabView {
                MapView()
                    .ignoresSafeArea(.container, edges: .top)
                    .tabItem{
                        Label("Peta", image: "map")
                    }
                
                AgendaView()
                    .ignoresSafeArea(.container, edges: .top)
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
        .environmentObject(plantManager)
        .environmentObject(taskManager)
    }
}
