//
//  PlantDetailView.swift
//  greenlake-companion
//
//  Created by AI Assistant on 28/08/25.
//

import SwiftUI

struct PlantDetailView: View {
  let plant: PlantInstance
  let onDelete: (PlantInstance) -> Void
  let onDismiss: () -> Void
  let onSave: (UUID, String?, PlantType) -> Void

  @State private var nameInput: String = ""
  @State private var typeInput: PlantType = .tree

  var body: some View {
    NavigationStack {

      Form {
        Section(header: Text("Details")) {
          TextField("Name", text: $nameInput)
            .textInputAutocapitalization(.words)
            .disableAutocorrection(true)

          Picker("Type", selection: $typeInput) {
            ForEach(PlantType.allCases) { type in
              Text(type.displayName).tag(type)
            }
          }
        }
      }
      .scrollContentBackground(.hidden)
      .background(.clear)
      .onAppear {
        nameInput = plant.name ?? ""
        typeInput = plant.type
      }
      .navigationTitle(plant.name ?? "Plant Details")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button(action: { onDismiss() }) {
            Image(systemName: "xmark")
              .font(.body)
              .foregroundColor(.secondary)
          }
        }
      }
    }
  }
}
