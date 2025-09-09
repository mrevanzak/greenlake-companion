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
        VStack(spacing: 8) {
            ForEach(PlantType.allCases) { type in
                Button(action: { filterVM.toggle(type) }) {
                    Image(systemName: iconForPlantType(type))
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(filterVM.selectedPlantTypes.contains(type) ? .green : .secondary)
                        .padding(10)
                        .background(filterVM.selectedPlantTypes.contains(type) ?
                                    Color.green.opacity(0.2) : Color.clear)
                    
                }
                .accessibilityLabel("\(type.displayName) filter")
                
//                if type != PlantType.allCases.last {
//                    Divider()
//                }
            }
            //            Divider()
            
        }
        .background(.ultraThinMaterial)
        .cornerRadius(8)
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
