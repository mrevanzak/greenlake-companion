//
//  AccountButton.swift
//  greenlake-companion
//
//  Created by Theodore Michael Budiono on 03/09/25.
//

import SwiftUI

struct AccountButton: View {
    @EnvironmentObject private var authManager: AuthManager
    @State private var isExpanded = false
    @Environment(\.colorScheme) private var colorScheme

    var name: String {
        authManager.currentUser?.name ?? "Unknown"
    }
    var role: String {
        authManager.currentUser?.role.capitalized ?? "Unknown"
    }
    
    var body: some View {
//        HStack {
//            TopControlView()
            VStack(alignment: .leading, spacing: 0) {
                
                VStack(spacing: 8) {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isExpanded.toggle()
                        }
                    }) {
                        HStack(alignment: .top, spacing: 16) {
                            
                            if isExpanded {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                                
                                VStack(alignment : .leading , spacing: 0) {
                                    Text(name)
                                        .font(.system(size: 16, weight: .semibold))
                                    //                                .padding(.vertical, 6)
                                    //                                .padding(.horizontal, 6)
                                        .foregroundColor(.primary)
                                    Text(role)
                                        .font(.system(size: 16, weight: .regular))
                                        .italic()
                                    //                                .padding(.vertical, 6)
                                    //                        .padding(.horizontal, 6)
                                        .foregroundColor(.primary)
                                        .opacity(0.7)
                                }
                                Image(systemName: "xmark")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                                    .padding(.top, 4)
                            } else {
                                
                                HStack(alignment : .top, spacing: 6) {
                                    
                                    
                                    
                                    Text(name)
                                        .font(.system(size: 16, weight: .semibold))
                                    //                                .padding(.vertical, 6)
                                    //                                .padding(.horizontal, 6)
                                        .foregroundColor(.primary)
                                    
                                    Text(role)
                                        .font(.system(size: 16, weight: .regular))
                                        .italic()
                                    //                                .padding(.vertical, 6)
                                    //                        .padding(.horizontal, 6)
                                        .foregroundColor(.primary)
                                        .opacity(0.7)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, isExpanded ? 10 : 8)
                .background(.thinMaterial)
                .cornerRadius(17)
                
                VStack(alignment: .trailing, spacing: 8) {
                    if isExpanded {
                        
                        
                        Button(action: {
                            authManager.logout()
                        }) {
                            HStack(spacing: 8) {
                                
                                Text("Logout")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(.red)
                            }
                            
                        }
                        .transition(.opacity.combined(with: .scale))
                    }
                }
                .padding(isExpanded ? .horizontal : .horizontal, 16)
                .padding(.vertical, isExpanded ? 8 : 0)
            }
            .padding(3)
            //            .padding(.vertical, 8)
            .background(.thinMaterial.opacity(isExpanded ? 0.8 : 0))
            .cornerRadius(20)
            .shadow(color: isExpanded ? .black.opacity(0.3) : .clear, radius: 8, x: 0, y: 0)
//        Spacer()
        }
            
    }
//}

//#Preview {
//    AccountButton()
//        .environmentObject(AuthManager.shared)
//}
