//
//  HomeView.swift
//  greenlake-companion
//
//  Created by AI Assistant on 21/08/25.
//

import SwiftUI

/// Main home view that presents the maps interface
struct HomeView: View {
  @State private var showSheet = true
  @State private var useCustomTiles = false

  var body: some View {
    MapsView(useCustomTiles: $useCustomTiles)
      .adaptiveSheet(
        isPresented: $showSheet,
        configuration: AdaptiveSheetConfiguration(detents: [.height(100), .medium, .large])
      ) {
        CustomTileBottomSheetContent(useCustomTiles: $useCustomTiles)
      }
  }
}

#Preview {
  HomeView()
}
