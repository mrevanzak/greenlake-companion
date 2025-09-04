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
class CreateTaskViewModel: ObservableObject {
  // MARK: - Published Properties

  @Published var selectedImages: [PhotosPickerItem] = []
  @Published var selectedConditionTags: Set<PlantConditionTag> = []
  @Published var description: String = ""
  @Published var taskName: String = ""
  @Published var location: String = ""
  @Published var taskType: TaskType = .minor
  @Published var area: String = ""
  @Published var unit: UnitType = .m2
  @Published var dueDate: Date =
    Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
  @Published var isLoading: Bool = false
  @Published var errorMessage: String?
  @Published var showErrorAlert: Bool = false
  @Published private(set) var imageData: [Data] = []

  // MARK: - Field Error States

  @Published var taskNameError: String?
  @Published var descriptionError: String?
  @Published var dueDateError: String?

  // MARK: - Private Properties

  private let plantInstance: PlantInstance
  private let taskService: TaskServiceProtocol

  // MARK: - Initialization

  init(plant: PlantInstance, taskService: TaskServiceProtocol = TaskService()) {
    self.plantInstance = plant
    self.taskService = taskService
  }

  // MARK: - Public Methods

  /// Handle updates to PhotosPicker selections and load image data
  func handlePhotosSelectionChanged() async {
    await processSelectedImages()
  }

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
    hasTaskName && isDescriptionValid && isDueDateValid
      && (hasSelectedConditions || hasDescription || !imageData.isEmpty)
  }

  /// Save task to the backend
  func saveTask() async {
    guard validateFields() else { return }

    isLoading = true
    clearGlobalError()

    // Convert PhotosPicker items to Data if needed
    await processSelectedImages()

    do {
      // Create the task request
      let request = CreateTaskRequest(
        taskName: taskName,
        urgency: taskType,
        dueDate: dueDate,
        plantId: plantInstance.id,
        area: Double(area.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "0" : area),
        unit: unit.rawValue,
        description: description.isEmpty ? nil : description,
        location: location,
        conditions: selectedConditionTags.isEmpty ? nil : selectedConditionTags.map { $0.rawValue }
      )

      // Call the API to create the task
      let _ = try await taskService.createTask(request, with: imageData)

      // Reset form after successful save
      resetForm()

    } catch {
      print("❌ Error saving task: \(error)")
      setGlobalError("Gagal menyimpan tugas. Silakan coba lagi.")
    }

    isLoading = false
  }

  /// Reset form to initial state
  func resetForm() {
    taskName = ""
    selectedConditionTags.removeAll()
    location = ""
    description = ""
    taskType = .minor
    unit = .m2
    area = ""
    dueDate = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    clearImages()
    clearGlobalError()
    clearFieldErrors()
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

  /// Generate location string from plant coordinates
  private func generateLocationString() -> String {
    return "Lat: \(plantInstance.location.latitude), Lng: \(plantInstance.location.longitude)"
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

  // MARK: - Validation

  private let maxDescriptionLength: Int = 500
  private let maxImageCount: Int = 6

  /// Public accessors for UI
  var descriptionLimit: Int { maxDescriptionLength }
  var imageLimit: Int { maxImageCount }

  @discardableResult
  func validateFields() -> Bool {
    clearFieldErrors()

    var isValid = true

    // Task name validation
    if !hasTaskName {
      taskNameError = "Nama tugas wajib diisi"
      isValid = false
    } else if taskName.count < 3 {
      taskNameError = "Nama tugas minimal 3 karakter"
      isValid = false
    }

    // Description length validation
    if !isDescriptionValid {
      descriptionError = "Deskripsi maksimal \(maxDescriptionLength) karakter"
      isValid = false
    }

    // Due date validation
    if !isDueDateValid {
      dueDateError = "Jatuh tempo tidak boleh di masa lalu"
      isValid = false
    }

    // At least one detail provided (conditions, description, or image)
    if !(hasSelectedConditions || hasDescription || !imageData.isEmpty) {
      setGlobalError("Pilih minimal satu kondisi, tambahkan deskripsi, atau unggah gambar")
      isValid = false
    }

    // Image count limit
    if imageData.count > maxImageCount {
      setGlobalError("Maksimal \(maxImageCount) gambar")
      isValid = false
    }

    return isValid
  }

  func clearFieldErrors() {
    taskNameError = nil
    descriptionError = nil
    dueDateError = nil
  }

  func setGlobalError(_ message: String) {
    errorMessage = message
    showErrorAlert = true
  }

  func clearGlobalError() {
    errorMessage = nil
    showErrorAlert = false
  }
}

// MARK: - Image Processing Extensions

extension CreateTaskViewModel {
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

extension CreateTaskViewModel {
  /// Validate description length
  var isDescriptionValid: Bool {
    description.count <= 500  // Max 500 characters
  }

  /// Validate due date is not in the past
  var isDueDateValid: Bool {
    dueDate >= Date()
  }

  /// Validate task name non-empty
  var hasTaskName: Bool {
    !taskName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
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
