//
//  HomeView.swift
//  greenlake-companion
//
//  Created by AI Assistant on 21/08/25.
//

import SwiftUI

/// Main home view that presents the maps interface
struct HomeView: View {
  @State private var useCustomTiles = false

  var body: some View {
    MapsView(useCustomTiles: $useCustomTiles)
      .adaptiveSheet(
        isPresented: .constant(true),
        configuration: AdaptiveSheetConfiguration(detents: [.height(100), .large])
      ) {
        CustomTileBottomSheetContent(useCustomTiles: $useCustomTiles)
      }
  }
}

#Preview {
  HomeView()
}
