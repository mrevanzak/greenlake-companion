//
//  TopControlView.swift
//  greenlake-companion
//
//  Created by Theodore Michael Budiono on 03/09/25.
//

import SwiftUI

struct TopControlView: View {
  @EnvironmentObject private var filterVM: MapFilterViewModel
  @State private var selectedItem: String = "Pencatatan"
  @State private var showMenu = false
  @Environment(\.colorScheme) private var colorScheme

  private let items = ["Pencatatan", "Ubah Peta"]

  var body: some View {
    HStack(alignment: .top) {
      Text("Mode")
        .foregroundColor(.primary)
        .font(.system(size: 16, weight: .semibold))
        .frame(height: 32)
        .opacity(0.7)
      expandableButton
    }
    .padding(4)
    .padding(.leading, 12)
    .background(Color(.systemGray5).opacity(0.3))
    .background(.ultraThinMaterial)
    .cornerRadius(20)
  }

  private var expandableButton: some View {
    Button(action: {
      withAnimation(.easeInOut(duration: 0.3)) {
        showMenu.toggle()
      }
    }) {
      HStack(alignment: .top, spacing: 8) {
        VStack(alignment: .leading, spacing: 0) {
          if showMenu {
            ForEach(items, id: \.self) { item in
              Button(action: {
                selectedItem = item
                withAnimation(.easeInOut(duration: 0.3)) {
                  showMenu = false
                }
              }) {
                Text(item)
                  .font(.system(size: 16, weight: .semibold))
                  .foregroundColor(.primary)
                  .padding(.vertical, 6)
                  .padding(.horizontal, 6)
                //                                        .padding()
                //                                        .frame(maxWidth: .infinity, alignment: .leading)
              }
            }

          } else {
            Text(selectedItem)
              .font(.system(size: 16, weight: .semibold))
              .padding(.vertical, 6)
              .padding(.horizontal, 6)
              .foregroundColor(.primary)
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)

        Image(systemName: "chevron.down")
          .foregroundColor(showMenu ? .primary : .primary)
          .rotationEffect(.degrees(showMenu ? 180 : 0))
          .animation(.easeInOut(duration: 0.3), value: showMenu)
          .frame(width: 24, height: 32)
        //                        .background(.black)

      }
      .padding(.horizontal, 8)
      //                .padding(.vertical, 8)
      //                .frame(height: showMenu ? 100 : 44)
      .frame(width: 175)
      .background(Color.white.opacity(colorScheme == .dark ? 0.1 : 1.0))
      .clipShape(RoundedRectangle(cornerRadius: 16))
    }
  }
}

//#Preview {
//    TopControlView()
//}
