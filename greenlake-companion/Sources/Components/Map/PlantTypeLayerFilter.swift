//
//  PlantTypeLayerFilter.swift
//  greenlake-companion
//
//  Created by Theodore Michael Budiono on 06/09/25.
//

import SwiftUI

struct PlantTypeLayerFilter: View {
    @EnvironmentObject private var filterVM: MapFilterViewModel
    
    var body: some View {
        Menu {
            ForEach(PlantType.allCases) { type in
                Button(action: { filterVM.toggle(type) }) {
                    Label(
                        type.displayName,
                        systemImage: filterVM.selectedPlantTypes.contains(type)
                            ? "checkmark.circle.fill" : "circle"
                    )
                }
            }
            Divider()
            Button("Show All", action: { filterVM.showAll() })
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "square.3.layers.3d.down.right")
                Text("Layers")
            }
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
        }
        .accessibilityLabel("Layer filters")
    }
}
