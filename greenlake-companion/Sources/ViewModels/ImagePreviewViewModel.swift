import SwiftUI

@MainActor
class ImagePreviewViewModel: ObservableObject {
  @Published var currentIndex: Int
  @Published var scale: CGFloat = 1.0
  @Published var offset: CGSize = .zero

  init(selectedIndex: Int = 0) {
    self.currentIndex = selectedIndex
  }

  func resetZoom() {
    withAnimation(.spring()) {
      scale = 1.0
      offset = .zero
    }
  }
}
