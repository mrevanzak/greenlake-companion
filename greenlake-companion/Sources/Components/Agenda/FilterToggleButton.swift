//
//  FilterToggleButton.swift
//  greenlake-companion
//
//  Created by Savio Enoson on 01/09/25.
//


import SwiftUI

struct FilterToggleButton<Parameter: RawRepresentable & Equatable & Hashable>: View where Parameter.RawValue == String {
  let parameter: Parameter
  @Binding var selection: [Parameter]
  
  private var isToggled: Bool {
    selection.contains(parameter)
  }
  
  var body: some View {
    Button {
      if isToggled {
        selection.removeAll { $0 == parameter }
      } else {
        selection.append(parameter)
      }
    } label: {
      Text(parameter.rawValue)
        .font(.footnote)
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(isToggled ? .blue : Color.secondary.opacity(0.6))
        .foregroundColor(.white)
        .cornerRadius(10)
    }
    .animation(.easeInOut(duration: 0.2), value: isToggled)
  }
}
