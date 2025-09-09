import SwiftUI

struct ImagePreviewView: View {
  let images: [Photo]
  @Binding var isPresented: Bool
  @StateObject private var viewModel: ImagePreviewViewModel

  init(images: [Photo], selectedIndex: Int, isPresented: Binding<Bool>) {
    self.images = images
    self._isPresented = isPresented
    _viewModel = StateObject(wrappedValue: ImagePreviewViewModel(selectedIndex: selectedIndex))
  }

  var body: some View {
    ZStack(alignment: .topTrailing) {
      Color.black.ignoresSafeArea()

      TabView(selection: $viewModel.currentIndex) {
        ForEach(Array(images.enumerated()), id: \.element) { index, photo in
          ZoomableImageView(photo: photo, viewModel: viewModel)
            .tag(index)
            .accessibilityLabel("Image \(index + 1) of \(images.count)")
            .accessibilityHint("Pinch to zoom, swipe left or right to navigate")
        }
      }
      .tabViewStyle(.page(indexDisplayMode: .never))
      .onChange(of: viewModel.currentIndex) { _, _ in
        viewModel.resetZoom()
      }

      Button("Done") {
        isPresented = false
      }
      .padding()
      .foregroundColor(.white)
      .accessibilityLabel("Done")
    }
    .gesture(
      DragGesture()
        .onEnded { value in
          if value.translation.height > 100 {
            isPresented = false
          }
        }
    )
  }
}
