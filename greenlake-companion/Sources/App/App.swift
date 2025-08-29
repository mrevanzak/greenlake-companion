//
//  App.swift
//  greenlake-companion
//
//  Created by Revanza Kurniawan on 21/08/25.
//

//import SwiftUI
//
//@main
//struct GreenlakeCompanionApp: App {
//  var body: some Scene {
//    WindowGroup {
//      MapView()
//    }
//  }
//}

import SwiftUI

@main
struct GreenlakeCompanionApp: App {
    @StateObject private var authManager = AuthManager.shared
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authManager.isAuthenticated {
                    // Your main app content - replace with your main view
                    Text("Main App Content")
                        .onAppear {
                            // Load user data when app starts
                            authManager.loadUserFromStorage()
                        }
                    Button("Logout") {
                        AuthManager.shared.logout()
                    }
                } else {
                    LoginView()
                }
            }
            .environmentObject(authManager)
        }
    }
}
