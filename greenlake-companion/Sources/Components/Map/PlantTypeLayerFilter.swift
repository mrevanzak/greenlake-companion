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
        VStack(spacing: 4) {
            ForEach(PlantType.allCases) { type in
                Button(action: { filterVM.toggle(type) }) {
                    Image(systemName: iconForPlantType(type))
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(filterVM.selectedPlantTypes.contains(type) ? .primary : .secondary.opacity(0.5))
                        .padding(10)
                        .background(Color.clear)
                }
                .accessibilityLabel("\(type.displayName) filter")
            }
        }
        .frame(width : 46)
        .padding(.vertical, 4)
        .background(.thinMaterial)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.08), radius: 14, x: 0, y: 0)
    }
    
    private func iconForPlantType(_ type: PlantType) -> String {
        switch type {
        case .tree:
            return "tree"
        case .groundCover:
            return "leaf"
        case .bush:
            return "leaf.circle"
        }
    }
}

//#Preview {
//    PlantTypeLayerFilter()
//}
