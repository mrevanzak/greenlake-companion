//
//  TopControlView.swift
//  greenlake-companion
//
//  Created by Theodore Michael Budiono on 03/09/25.
//

import SwiftUI

struct TopControlView: View {
    @EnvironmentObject private var filterVM: MapFilterViewModel
    @State private var selectedItem: String = "Mode"
    @State private var showMenu = false
    
    private let items = ["Pencatatan", "Ubah Peta"]
    
    var body: some View {
        HStack (alignment: .top) {
            VStack(alignment: .leading, spacing: 0) {
                expandableButton
                Spacer()
            }
            Spacer()
        }
            .padding(.top, 29)
            .padding(.horizontal, 16)
        }
        
        private var expandableButton: some View {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showMenu.toggle()
                }
            }) {
                HStack (alignment: .top, spacing : 8) {
                    VStack(alignment: .leading, spacing: 16) {
                    if showMenu {
                            ForEach(items, id: \.self) { item in
                                Button(action: {
                                    selectedItem = item
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        showMenu = false
                                    }
                                }) {
                                    Text(item)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.primary)
//                                        .padding()
//                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                       

                    } else {
                        Text(selectedItem)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.primary)
//                            .padding()
                                            }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Image(systemName: "chevron.down")
                        .foregroundColor(showMenu ? .secondary : .primary)
                        .rotationEffect(.degrees(showMenu ? 180 : 0))
                        .animation(.easeInOut(duration: 0.3), value: showMenu)
                        .frame(width: 24, height: 24)
//                        .background(.black)
                   
                
                }
                .padding(.horizontal, 8)
//                .padding(.vertical, 8)
//                .frame(height: showMenu ? 100 : 44)
                .frame(width: 200)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
}
