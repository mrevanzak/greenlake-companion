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
  let onSave: (String?, PlantType, Double?) -> Void

  @State private var nameInput: String = ""
  @State private var typeInput: PlantType = .tree
  @State private var radiusInput: Double = 5.0

  var body: some View {
    NavigationStack {
      ZStack {
        Color(.systemBackground)
          .ignoresSafeArea()

        Form {
          Section(
            header: Text("Details"),
            footer: Text(
              "Coordinates: \(plant?.location.latitude ?? 0), \(plant?.location.longitude ?? 0)"
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

            if typeInput == .tree {
              HStack {
                Text("Radius")
                Spacer()
                Stepper(
                  value: $radiusInput,
                  in: 0.5...50.0,
                  step: 0.5
                ) {
                  Text("\(radiusInput, specifier: "%.1f") m")
                    .foregroundColor(.secondary)
                }
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
            radiusInput = plant.radius ?? 5.0
          }
        }
        .onChange(of: typeInput) { newType in
          if newType != .tree {
            radiusInput = 5.0  // Reset radius for non-tree types
          }
        }
        .navigationTitle(isCreationMode ? "New Plant" : (plant?.name ?? "Plant Details"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .topBarTrailing) {
            Button(action: {
              let radius = typeInput == .tree ? radiusInput : nil
              onSave(nameInput, typeInput, radius)
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
