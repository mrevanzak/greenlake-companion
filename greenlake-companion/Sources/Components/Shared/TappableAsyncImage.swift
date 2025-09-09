import SwiftUI

struct TappableAsyncImage: View {
  let photo: Photo
  let images: [Photo]
  let selectedIndex: Int

  @State private var showingImagePreview = false

  var body: some View {
    AsyncImage(url: URL(string: photo.thumbnailUrl)) { phase in
      switch phase {
      case .empty:
        ProgressView()
          .frame(height: 200)
      case .failure:
        Image(systemName: "photo")
          .resizable()
          .scaledToFit()
          .foregroundColor(.gray)
          .frame(height: 200)
      case .success(let image):
        image
          .resizable()
          .scaledToFit()
          .frame(height: 200)
          .cornerRadius(10)
          .onTapGesture { showingImagePreview = true }
          .accessibilityLabel("Image \(selectedIndex + 1) of \(images.count)")
          .accessibilityHint("Double tap to zoom, swipe to navigate")
          .accessibilityAddTraits(.isButton)
          .accessibilityAction {
            showingImagePreview = true
          }
      @unknown default:
        EmptyView()
          .frame(height: 200)
      }
    }
    .onAppear {
      preloadNextImage()
    }
    .sheet(isPresented: $showingImagePreview) {
      ImagePreviewView(images: images, selectedIndex: selectedIndex, isPresented: $showingImagePreview)
    }
  }

  private func preloadNextImage() {
    let nextIndex = selectedIndex + 1
    guard images.indices.contains(nextIndex) else { return }
    let nextUrlString = images[nextIndex].thumbnailUrl
    if let url = URL(string: nextUrlString) {
      let task = URLSession.shared.dataTask(with: url) { _, _, _ in }
      task.resume()
    }
  }
}
