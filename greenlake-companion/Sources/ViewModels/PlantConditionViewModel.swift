//
//  PlantConditionViewModel.swift
//  greenlake-companion
//
//  Created by AI Assistant on 05/01/25.
//

import Foundation
import PhotosUI
import SwiftUI

@MainActor
class PlantConditionViewModel: ObservableObject {
  // MARK: - Published Properties

  @Published var selectedImages: [PhotosPickerItem] = []
  @Published var selectedConditionTags: Set<PlantConditionTag> = []
  @Published var description: String = ""
  @Published var location: String = "Area Taman - The GreenLake ClubHouse"
  @Published var isLoading: Bool = false
  @Published var errorMessage: String?
  @Published var showingImagePicker: Bool = false
  @Published var showingCamera: Bool = false

  // MARK: - Private Properties

  private let plantInstance: PlantInstance
  private var imageData: [Data] = []
  private let plantConditionService = PlantConditionService.shared

  // MARK: - Initialization

  init() {
    self.plantInstance = PlantInstance(
      type: .tree,
      name: "Pine Tree",
      location: CLLocationCoordinate2D(latitude: -7.250445, longitude: 112.768845),
      radius: 5.0,
      createdAt: Date(),
      updatedAt: Date()
    )
  }

  // MARK: - Public Methods

  /// Toggle condition tag selection
  func toggleConditionTag(_ tag: PlantConditionTag) {
    if selectedConditionTags.contains(tag) {
      selectedConditionTags.remove(tag)
    } else {
      selectedConditionTags.insert(tag)
    }
  }

  /// Clear all selected condition tags
  func clearConditionTags() {
    selectedConditionTags.removeAll()
  }

  /// Add image data from PhotosPicker
  func addImageData(_ data: Data) {
    imageData.append(data)
  }

  /// Remove image at specific index
  func removeImage(at index: Int) {
    guard index < imageData.count else { return }
    imageData.remove(at: index)

    // Also remove from PhotosPicker selection if possible
    if index < selectedImages.count {
      selectedImages.remove(at: index)
    }
  }

  /// Clear all selected images
  func clearImages() {
    imageData.removeAll()
    selectedImages.removeAll()
  }

  /// Get current image count
  var imageCount: Int {
    imageData.count
  }

  /// Check if any condition tags are selected
  var hasSelectedConditions: Bool {
    !selectedConditionTags.isEmpty
  }

  /// Check if description is not empty
  var hasDescription: Bool {
    !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }

  /// Check if form is valid for submission
  var isFormValid: Bool {
    hasSelectedConditions || hasDescription || !imageData.isEmpty
  }

  /// Save plant condition record
  func savePlantCondition() async {
    guard isFormValid else {
      errorMessage = "Pilih minimal satu kondisi, tambahkan deskripsi, atau unggah gambar"
      return
    }

    isLoading = true
    errorMessage = nil

    do {
      // Convert PhotosPicker items to Data if needed
      await processSelectedImages()

      // Create plant condition record
      let plantCondition = PlantCondition(
        plantId: plantInstance.id,
        conditionTags: Array(selectedConditionTags),
        description: description,
        images: imageData,
        recordedAt: Date(),
        location: location
      )

      // Save using the plant condition service
      try await plantConditionService.savePlantCondition(plantCondition)

      // Reset form after successful save
      resetForm()

    } catch {
      errorMessage = "Gagal menyimpan kondisi tanaman: \(error.localizedDescription)"
    }

    isLoading = false
  }

  /// Reset form to initial state
  func resetForm() {
    selectedConditionTags.removeAll()
    description = ""
    clearImages()
    errorMessage = nil
  }

  /// Get plant name for display
  var plantName: String {
    plantInstance.name
  }

  /// Get plant scientific name for display
  var plantScientificName: String {
    // For now, return a placeholder. In a real app, this would come from the plant data
    switch plantInstance.name.lowercased() {
    case "pine tree", "pohon pinus":
      return "Pinus merkusii"
    default:
      return "Species name"
    }
  }

  // MARK: - Private Methods

  /// Process selected PhotosPicker items and convert to Data
  private func processSelectedImages() async {
    imageData.removeAll()

    for item in selectedImages {
      do {
        if let data = try await item.loadTransferable(type: Data.self) {
          imageData.append(data)
        }
      } catch {
        print("Failed to load image data: \(error)")
      }
    }
  }
}

// MARK: - Image Processing Extensions

extension PlantConditionViewModel {
  /// Get image data at specific index
  func imageData(at index: Int) -> Data? {
    guard index < imageData.count else { return nil }
    return imageData[index]
  }

  /// Get UIImage from data at specific index
  func image(at index: Int) -> UIImage? {
    guard let data = imageData(at: index) else { return nil }
    return UIImage(data: data)
  }

  /// Get all images as UIImage array
  var images: [UIImage] {
    imageData.compactMap { UIImage(data: $0) }
  }
}

// MARK: - Validation Extensions

extension PlantConditionViewModel {
  /// Validate description length
  var isDescriptionValid: Bool {
    description.count <= 500  // Max 500 characters
  }

  /// Get description character count
  var descriptionCharacterCount: Int {
    description.count
  }

  /// Get remaining characters for description
  var remainingDescriptionCharacters: Int {
    max(0, 500 - description.count)
  }
}
