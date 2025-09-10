//
//  TaskStatusViewModel.swift
//  greenlake-companion
//
//  Created by Akmal Ariq on 08/09/25.
//

import Foundation
import UIKit

@MainActor
final class TaskStatusViewModel: ObservableObject {
  enum SubmitState { case idle, submitting, success, failure(String) }

  @Published var status: String = ""
  @Published var note: String = ""
  @Published var selectedImages: [UIImage] = []
  @Published var submitState: SubmitState = .idle
  @Published var canSubmit: Bool = false

  private let taskId: UUID
  private let service: TaskServiceProtocol

  init(taskId: UUID, service: TaskServiceProtocol = TaskService()) {
    self.taskId = taskId
    self.service = service
    validate()
  }

  func validate() {
    canSubmit = !status.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }

  // UI layer should pass already-loaded UIImages here (keeps VM platform-agnostic)
  func addImages(_ images: [UIImage]) {
    selectedImages.append(contentsOf: images)
  }

  func removeImage(at index: Int) {
    guard selectedImages.indices.contains(index) else { return }
    selectedImages.remove(at: index)
  }

  func submit() async {
    guard canSubmit else { return }
    submitState = .submitting

    // Convert images to JPEG data here (no dependency on TaskService.jpegData)
    let jpegDatas: [Data] = selectedImages.compactMap { $0.jpegData(compressionQuality: 0.8) }

    do {
      _ = try await service.updateTaskStatus(
        id: taskId,
        status: status,
        note: note.isEmpty ? nil : note,
        photos: jpegDatas
      )
      submitState = .success
    } catch {
      submitState = .failure((error as? LocalizedError)?.errorDescription ?? "Gagal memperbarui status.")
      print("❌ Error submitting task status update: \(error)")
    }
  }
}
