//
//  PlantConditionSheet.swift
//  greenlake-companion
//
//  Created by AI Assistant on 05/01/25.
//

import CoreLocation
import PhotosUI
import SwiftUI

struct CreateTaskView: View {
  @Environment(\.dismiss) private var dismiss

  @StateObject private var viewModel: CreateTaskViewModel

  @State private var showingImagePicker = false
  @State private var showingCamera = false

  let plant: PlantInstance

  init() {
    let plant = PlantManager.shared.selectedPlant ?? PlantInstance.empty()
    self._viewModel = StateObject(
      wrappedValue: CreateTaskViewModel(plant: plant))
    self.plant = plant
  }

  var body: some View {
    NavigationView {
      Form {
        plantInfoSection

        taskDetailSection

        Section("Dokumentasi") {
          imagesRow
          imagesUploadRow
        }

        Section("Kondisi Tanaman") {
          conditionTagsSection
        }

      }
      .navigationTitle("Catat Kondisi Tanaman")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Button("Batal") {
            dismiss()
          }
          .foregroundColor(.primary)
        }

        ToolbarItem(placement: .navigationBarTrailing) {
          Button("Simpan") {
            Task {
              await viewModel.saveTask()
              dismiss()
            }
          }
          .disabled(!viewModel.isFormValid || viewModel.isLoading)
          .foregroundColor(viewModel.isFormValid ? .accentColor : .secondary)
        }
      }
    }
    .photosPicker(
      isPresented: $showingImagePicker,
      selection: $viewModel.selectedImages,
      maxSelectionCount: 6,
      matching: .images
    )
    .onChange(of: viewModel.selectedImages) {
      Task { await viewModel.handlePhotosSelectionChanged() }
    }
    .sheet(isPresented: $showingCamera) {
      CameraView(
        onImageCaptured: { image in
          if let imageData = image.jpegData(compressionQuality: 0.8) {
            viewModel.addImageData(imageData)
          }
        },
        onDismiss: {
          showingCamera = false
        }
      )
    }
  }

  // MARK: - Images Section

  private var imagesRow: some View {
    VStack(alignment: .leading, spacing: 12) {
      if viewModel.imageCount > 0 {
        LazyVGrid(
          columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3), spacing: 8
        ) {
          ForEach(0..<viewModel.imageCount, id: \.self) { index in
            if let image = viewModel.image(at: index) {
              Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 100)
                .clipped()
                .cornerRadius(12)
                .overlay(
                  Button(action: {
                    viewModel.removeImage(at: index)
                  }) {
                    Image(systemName: "xmark.circle.fill")
                      .foregroundColor(.white)
                      .background(Color.black.opacity(0.6))
                      .clipShape(Circle())
                  }
                  .padding(4),
                  alignment: .topTrailing
                )
            }
          }
        }
      } else {
        RoundedRectangle(cornerRadius: 12)
          .fill(Color(.systemGray6))
          .frame(height: 120)
          .overlay(
            VStack(spacing: 8) {
              Image(systemName: "photo")
                .font(.system(size: 32))
                .foregroundColor(.secondary)
              Text("Belum ada gambar")
                .font(.caption)
                .foregroundColor(.secondary)
            }
          )
      }
    }
  }

  // MARK: - Image Upload

  private var imagesUploadRow: some View {
    HStack(spacing: 12) {
      Button(action: {
        showingImagePicker = true
      }) {
        HStack {
          Image(systemName: "photo.on.rectangle")
          Text("Unggah gambar")
        }
        .frame(maxWidth: .infinity)
      }
      .buttonStyle(.primary)

      Button(action: {
        showingCamera = true
      }) {
        HStack {
          Image(systemName: "camera")
          Text("Buka Kamera")
        }
        .frame(maxWidth: .infinity)
      }
      .buttonStyle(.secondary)
    }
  }

  // MARK: - Condition Tags Section

  private var conditionTagsSection: some View {
    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8) {
      ForEach(PlantConditionTag.allCases) { tag in
        Button(action: {
          viewModel.toggleConditionTag(tag)
        }) {
          HStack {
            Image(systemName: tag.icon)
              .foregroundColor(viewModel.selectedConditionTags.contains(tag) ? .white : tag.color)
            Text(tag.rawValue)
              .font(.subheadline)
              .foregroundColor(viewModel.selectedConditionTags.contains(tag) ? .white : .primary)
          }
          .frame(maxWidth: .infinity)
          .padding(.horizontal, 12)
          .padding(.vertical, 10)
          .background(
            viewModel.selectedConditionTags.contains(tag)
              ? tag.color
              : Color(.systemGray5)
          )
          .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
      }
    }
  }

  // MARK: - Sections

  private var plantInfoSection: some View {
    Section("Informasi Tanaman") {
      Label(plant.name, systemImage: "leaf.fill")
      Label(
        "\(plant.location.latitude.description), \(plant.location.longitude.description)",
        systemImage: "mappin.and.ellipse"
      )
      Label(plant.type.displayName, systemImage: "tree")
    }
  }

  private var taskDetailSection: some View {
    Section("Detail Tugas") {
      TextField("Nama Tugas", text: $viewModel.taskName)
        .textInputAutocapitalization(.sentences)
        .autocorrectionDisabled(false)
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .stroke(viewModel.taskNameError == nil ? Color.clear : Color.red, lineWidth: 1)
        )
      if let taskNameError = viewModel.taskNameError {
        Text(taskNameError)
          .font(.caption)
          .foregroundColor(.red)
      }

      Picker("Jenis Tugas", selection: $viewModel.taskType) {
        ForEach(TaskType.allCases) { type in
          Text(type.displayName).tag(type)
        }
      }

      DatePicker(
        "Jatuh Tempo",
        selection: $viewModel.dueDate,
        in: Date()...,
        displayedComponents: [.date, .hourAndMinute]
      )
      .overlay(
        RoundedRectangle(cornerRadius: 8)
          .stroke(viewModel.dueDateError == nil ? Color.clear : Color.red, lineWidth: 1)
      )
      if let dueDateError = viewModel.dueDateError {
        Text(dueDateError)
          .font(.caption)
          .foregroundColor(.red)
      }

      TextField("Deskripsi", text: $viewModel.description, axis: .vertical)
        .lineLimit(5...10)
        .overlay(
          RoundedRectangle(cornerRadius: 12)
            .stroke(viewModel.isDescriptionValid ? Color.clear : Color.red, lineWidth: 1)
        )
      HStack {
        if let descriptionError = viewModel.descriptionError {
          Text(descriptionError)
            .font(.caption)
            .foregroundColor(.red)
        }
        Spacer()
        Text("\(viewModel.descriptionCharacterCount)/\(viewModel.descriptionLimit)")
          .font(.caption2)
          .foregroundColor(.secondary)
      }
    }
  }
}

// MARK: - Preview

struct CreateTaskView_Previews: PreviewProvider {
  static var previews: some View {
    Color.clear
      .sheet(isPresented: .constant(true)) {
        CreateTaskView()
      }
  }
}
