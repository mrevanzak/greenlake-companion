//
//  AccountButton.swift
//  greenlake-companion
//
//  Created by Theodore Michael Budiono on 03/09/25.
//


//
//  AccountButton.swift
//  greenlake-companion
//
//  Created by Theodore Michael Budiono on 03/09/25.
//

import SwiftUI

struct AccountButton: View {
    @EnvironmentObject private var authManager: AuthManager
    
    var body: some View {
        Button(action: {
            authManager.logout()
        }) {
            HStack(spacing: 8) {
                Text("Melisa Aprina")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
        }
    }
}
