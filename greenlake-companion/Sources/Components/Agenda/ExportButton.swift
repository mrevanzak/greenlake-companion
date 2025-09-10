//
//  ExportButton.swift
//  greenlake-companion
//
//  Created by Theodore Michael Budiono on 10/09/25.
//


//
//  ExportButton.swift
//  greenlake-companion
//
//  Created by Theodore Michael Budiono on 03/09/25.
//

import SwiftUI

struct ExportButton: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                Text("Export")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.blue)
                    
            }
            
            if isExpanded {
                
                Divider()
                    .frame(width: 120)
                                    .padding(.horizontal, -16)
                                    .padding(.top, 8)
                                    
                VStack(alignment : .leading, spacing: 12) {
                    Button(action: {
                        print("Checklist")
                        isExpanded = false
                    }) {
                        HStack {
//                            Image(systemName: "checklist")
                            Text("Checklist")
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    }
                    
                    Button(action: {
                        print("Denda")
                        isExpanded = false
                    }) {
                        HStack {
//                            Image(systemName: "dollarsign")
                            Text("Denda")
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                       
                    }
                }
                .padding(.top, 8)
                .transition(.opacity.combined(with: .scale))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, isExpanded ? 10 : 8)
        .background(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.white.opacity(1))
        .cornerRadius(20)
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.4 : 0.08), radius: 14, x: 0, y: 0)
        
    }
}

#Preview {
    ExportButton()
}
