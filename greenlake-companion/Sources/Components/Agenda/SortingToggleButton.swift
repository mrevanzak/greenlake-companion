//
//  SortingToggleButton.swift
//  greenlake-companion
//
//  Created by Savio Enoson on 01/09/25.
//


import SwiftUI

struct SortingToggleButton: View {
    let mySortKey: SortKey
    @Binding var sortKeyController: SortKey
    @Binding var sortOrderController: SortingState
    
    private var currentState: SortingState {
        if sortKeyController == mySortKey {
            return sortOrderController
        } else {
            return .notSelected
        }
    }
    
    var body: some View {
        Button {
            if sortKeyController == mySortKey {
                switch sortOrderController {
                case .ascending:
                    sortOrderController = .descending
                case .descending:
                    sortKeyController = .dateCreated
                    sortOrderController = .ascending
                case .notSelected:
                    sortOrderController = .ascending
                }
            } else {
                sortKeyController = mySortKey
                sortOrderController = .ascending
            }
        } label: {
            let isSelected = currentState != .notSelected
            let foreColor: Color = isSelected ? .blue : .primary
            
            HStack {
                Text(mySortKey.rawValue)
                    .foregroundColor(foreColor)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: sortOrderController == .ascending ? "chevron.up" : "chevron.down")
                        .foregroundColor(foreColor)
                }
            }
            .padding(.vertical, 8)
        }
        .animation(.easeInOut, value: currentState)
    }
}
