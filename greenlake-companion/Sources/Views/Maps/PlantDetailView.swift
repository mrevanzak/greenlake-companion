//
//  PlantDetailView.swift
//  greenlake-companion
//
//  Created by AI Assistant on 28/08/25.
//

import SwiftUI

struct PlantDetailView: View {
  let plant: PlantInstance?
  let isCreationMode: Bool
  let onDelete: (PlantInstance) -> Void
  let onDismiss: () -> Void
  let onSave: (String?, PlantType) -> Void

  @State private var nameInput: String = ""
  @State private var typeInput: PlantType = .tree

  var body: some View {
    NavigationStack {
      ZStack {
        Color(.systemBackground)
          .ignoresSafeArea()

        Form {
          Section(
            header: Text("Details"),
            footer: Text(
              "Coordinates: \(plant?.coordinate.latitude ?? 0), \(plant?.coordinate.longitude ?? 0)"
            )
          ) {
            TextField("Name", text: $nameInput)
              .textInputAutocapitalization(.words)
              .disableAutocorrection(true)

            Picker("Type", selection: $typeInput) {
              ForEach(PlantType.allCases) { type in
                Text(type.displayName).tag(type)
              }
            }
          }
          .listRowBackground(Color.systemGray6)
        }
        .contentMargins(.horizontal, 4)
        .scrollContentBackground(.hidden)
        .background(.clear)
        .onAppear {
          if let plant = plant {
            nameInput = plant.name ?? ""
            typeInput = plant.type
          }
        }
        .navigationTitle(isCreationMode ? "New Plant" : (plant?.name ?? "Plant Details"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .topBarTrailing) {
            Button(action: {
              onSave(nameInput, typeInput)
            }) {
              Text("Save")
                .font(.body)
                .foregroundColor(.primary)
            }
          }
          ToolbarItem(placement: .topBarLeading) {
            Button(action: { onDismiss() }) {
              Text("Cancel")
                .font(.body)
                .foregroundColor(.secondary)
            }
          }
        }
      }
    }
  }
}
