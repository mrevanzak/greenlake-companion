//
//  ExportButton.swift
//  greenlake-companion
//
//  Created by Theodore Michael Budiono on 10/09/25.
//

import SwiftUI

struct ExportButton: View {
  @Environment(\.colorScheme) private var colorScheme
  @State private var isExpanded = false
  
  let checklistAction: () -> Void
  let dendaAction: () -> Void
  
  private let collapsedWidth: CGFloat = 53
  private let collapsedHeight: CGFloat = 36
  private let innerPadding: CGFloat = 10
  private let expandedWidth: CGFloat = 90
  
  var body: some View {
    Color.clear
      .frame(width: collapsedWidth, height: collapsedHeight)
      .overlay(
        expandingButton,
        alignment: .topTrailing
      )
  }
  
  private var expandingButton: some View {
    VStack(alignment: .leading, spacing: 0) {
      Button(action: {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
          isExpanded.toggle()
        }
      }) {
        Text("Export")
          .fixedSize(horizontal: true, vertical: false)
          .frame(width: isExpanded ? expandedWidth - innerPadding : collapsedWidth - innerPadding, alignment: .leading)
      }
      .font(.system(size: 16, weight: .medium))
      .foregroundColor(.blue)
      
      if isExpanded {
        Divider()
          .frame(width: expandedWidth + 32)
          .padding(.horizontal, -16)
          .padding(.top, 8)
        
        VStack(alignment: .leading, spacing: 12) {
          Button(action: {
            checklistAction()
            isExpanded = false
          }) {
            HStack {
              Text("Checklist")
            }
            .foregroundColor(.primary)
          }
          
          Button(action: {
            dendaAction()
            isExpanded = false
          }) {
            HStack {
              Text("Denda")
            }
            .foregroundColor(.primary)
          }
        }
        .font(.system(size: 16, weight: .medium))
        .padding(.top, 8)
        .transition(.opacity.combined(with: .scale(scale: 1.0, anchor: .topTrailing)))
      }
    }
    .frame(width: isExpanded ? expandedWidth : collapsedWidth, alignment: .topLeading)
    .padding(.horizontal, 16)
    .padding(.vertical, isExpanded ? 10 : 8)
    .background(Color.white)
//    .shadow(color: .black.opacity(colorScheme == .dark ? 0.4 : 0.08), radius: 14, x: 0, y: 0)
    .cornerRadius(20)
    .drawingGroup()
  }
}

#Preview {
    TabView {
      VStack(spacing: 20) {
        Text("Content Above the Button")
        
        HStack {
          Spacer()
          ExportButton(
            checklistAction: { print("Checklist button was tapped!") },
            dendaAction: { print("Denda button was tapped!") }
          )
          Spacer()
        }
        .padding()
        //.background(.ultraThinMaterial)
        .background {
          Capsule()
            .fill(Color(UIColor(.systemGray4)))
        }
        
        Text("Content Below the Button")
        
        Spacer()
      }
      .padding()
      .background(Color.gray.opacity(0.1))
      .tabItem {
        Label("Tab 1", image: "map")
      }
  
      VStack(spacing: 20) {
        Text("Content Above the Button")
        
        HStack {
          Image(systemName: "sidebar.left").font(.title2)
          Spacer()
          Text("Toolbar Title")
          Spacer()
          ExportButton(
            checklistAction: { print("Checklist button was tapped!") },
            dendaAction: { print("Denda button was tapped!") }
          )
        }
        .padding()
        .background(.ultraThinMaterial)
        
        Text("Content Below the Button")
        
        Spacer()
      }
      .padding()
      .background(Color.gray.opacity(0.1))
        .tabItem {
          Label("Tab 2", image: "map")
        }
    }
}

//#Preview {
//  TabView {
//    AgendaView()
//      .tabItem {
//        Label("Tab 1", image: "map")
//      }
//
//    AgendaView()
//      .tabItem {
//        Label("Tab 2", image: "map")
//      }
//  }
//}
