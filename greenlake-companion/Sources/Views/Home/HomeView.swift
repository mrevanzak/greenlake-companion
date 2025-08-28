//
//  HomeView.swift
//  greenlake-companion
//
//  Created by AI Assistant on 21/08/25.
//

import SwiftUI

/// Main home view that presents the maps interface
struct HomeView: View {
  var body: some View {
    MapView()
      .adaptiveSheet(
        isPresented: .constant(true),
        configuration: AdaptiveSheetConfiguration(detents: [.height(100), .large])
      ) {
        BottomSheetContent()
      }
  }
}

#Preview {
  HomeView()
}
