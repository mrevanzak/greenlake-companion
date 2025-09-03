//
//  CameraView.swift
//  greenlake-companion
//
//  Created by AI Assistant on 05/01/25.
//

import AVFoundation
import SwiftUI
import UIKit

struct CameraView: UIViewControllerRepresentable {
  let onImageCaptured: (UIImage) -> Void
  let onDismiss: () -> Void

  func makeUIViewController(context: Context) -> UIImagePickerController {
    let picker = UIImagePickerController()
    picker.delegate = context.coordinator
    picker.sourceType = .camera
    picker.allowsEditing = true
    picker.cameraDevice = .rear
    picker.cameraFlashMode = .auto
    return picker
  }

  func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
    // No updates needed
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let parent: CameraView

    init(_ parent: CameraView) {
      self.parent = parent
    }

    func imagePickerController(
      _ picker: UIImagePickerController,
      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
      if let editedImage = info[.editedImage] as? UIImage {
        parent.onImageCaptured(editedImage)
      } else if let originalImage = info[.originalImage] as? UIImage {
        parent.onImageCaptured(originalImage)
      }

      parent.onDismiss()
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
      parent.onDismiss()
    }
  }
}

// MARK: - Camera Permission Helper

extension CameraView {
  /// Check if camera is available on the device
  static var isCameraAvailable: Bool {
    UIImagePickerController.isSourceTypeAvailable(.camera)
  }

  /// Check if camera permission is granted
  static func checkCameraPermission() -> Bool {
    switch AVCaptureDevice.authorizationStatus(for: .video) {
    case .authorized:
      return true
    case .notDetermined, .denied, .restricted:
      return false
    @unknown default:
      return false
    }
  }

  /// Request camera permission
  static func requestCameraPermission() async -> Bool {
    await AVCaptureDevice.requestAccess(for: .video)
  }
}

// MARK: - Preview

#if DEBUG
  struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
      CameraView(
        onImageCaptured: { _ in },
        onDismiss: {}
      )
    }
  }
#endif
