//
//  PlantConditionSheet.swift
//  greenlake-companion
//
//  Created by AI Assistant on 05/01/25.
//

import CoreLocation
import PhotosUI
import SwiftUI

struct PlantConditionSheet: View {
  @StateObject private var viewModel: PlantConditionViewModel
  @Environment(\.dismiss) private var dismiss
  @State private var showingImagePicker = false
  @State private var showingCamera = false

  init() {
    self._viewModel = StateObject(
      wrappedValue: PlantConditionViewModel())
  }

  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 24) {
          locationSection
          plantNameSection
          plantImagesSection
          imageUploadSection
          conditionTagsSection
          descriptionSection
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 40)
      }
      .navigationTitle("Catat Kondisi Tanaman")
      .navigationBarTitleDisplayMode(.large)
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
              await viewModel.savePlantCondition()
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
    .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
      Button("OK") {
        viewModel.errorMessage = nil
      }
    } message: {
      if let errorMessage = viewModel.errorMessage {
        Text(errorMessage)
      }
    }
  }

  // MARK: - Location Section

  private var locationSection: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Lokasi")
        .font(.headline)
        .foregroundColor(.secondary)

      HStack {
        Image(systemName: "mappin.and.ellipse")
          .foregroundColor(.accentColor)
        Text(viewModel.location)
          .font(.subheadline)
          .foregroundColor(.primary)
        Spacer()
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 12)
      .background(Color(.systemGray6))
      .cornerRadius(12)
    }
  }

  // MARK: - Plant Name Section

  private var plantNameSection: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Nama Tanaman")
        .font(.headline)
        .foregroundColor(.secondary)

      VStack(alignment: .leading, spacing: 4) {
        Text(viewModel.plantName)
          .font(.title2)
          .fontWeight(.bold)
          .foregroundColor(.primary)

        Text(viewModel.plantScientificName)
          .font(.subheadline)
          .italic()
          .foregroundColor(.secondary)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(.horizontal, 16)
      .padding(.vertical, 12)
      .background(Color(.systemGray6))
      .cornerRadius(12)
    }
  }

  // MARK: - Plant Images Section

  private var plantImagesSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Gambar Tanaman")
        .font(.headline)
        .foregroundColor(.secondary)

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

  // MARK: - Image Upload Section

  private var imageUploadSection: some View {
    HStack(spacing: 12) {
      Button(action: {
        showingImagePicker = true
      }) {
        HStack {
          Image(systemName: "photo.on.rectangle")
          Text("Unggah gambar")
        }
        .font(.subheadline)
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.accentColor)
        .cornerRadius(12)
      }

      Button(action: {
        showingCamera = true
      }) {
        HStack {
          Image(systemName: "camera")
          Text("Buka Kamera")
        }
        .font(.subheadline)
        .foregroundColor(.accentColor)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.accentColor.opacity(0.1))
        .cornerRadius(12)
      }
    }
  }

  // MARK: - Condition Tags Section

  private var conditionTagsSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Kondisi Tanaman")
        .font(.headline)
        .foregroundColor(.secondary)

      LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 2), spacing: 8)
      {
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
  }

  // MARK: - Description Section

  private var descriptionSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Deskripsi")
        .font(.headline)
        .foregroundColor(.secondary)

      ZStack(alignment: .bottomTrailing) {
        TextEditor(text: $viewModel.description)
          .frame(minHeight: 120)
          .background(Color(.systemGray6))
          .cornerRadius(12)
          .overlay(
            RoundedRectangle(cornerRadius: 12)
              .stroke(viewModel.isDescriptionValid ? Color.clear : Color.red, lineWidth: 1)
          )

        VStack(alignment: .trailing, spacing: 4) {
          Button(action: {
            // Placeholder for voice input functionality
          }) {
            Image(systemName: "mic.fill")
              .foregroundColor(.accentColor)
              .padding(8)
              .background(Color(.systemBackground))
              .clipShape(Circle())
              .shadow(radius: 2)
          }
          .padding(8)

          if !viewModel.isDescriptionValid {
            Text("\(viewModel.descriptionCharacterCount)/500")
              .font(.caption)
              .foregroundColor(.red)
              .padding(.horizontal, 8)
          }
        }
      }

      if viewModel.isDescriptionValid && viewModel.descriptionCharacterCount > 0 {
        Text("\(viewModel.descriptionCharacterCount)/500")
          .font(.caption)
          .foregroundColor(.secondary)
          .frame(maxWidth: .infinity, alignment: .trailing)
      }
    }
  }
}

// MARK: - Preview

#Preview {
  PlantConditionSheet()
}
