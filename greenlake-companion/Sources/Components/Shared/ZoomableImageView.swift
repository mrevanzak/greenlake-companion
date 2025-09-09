import SwiftUI

struct ZoomableImageView: View {
  let photo: Photo
  @ObservedObject var viewModel: ImagePreviewViewModel

  @State private var baseScale: CGFloat = 1.0
  @State private var currentOffset: CGSize = .zero

  var body: some View {
    AsyncImage(url: URL(string: photo.imageUrl)) { phase in
      switch phase {
      case .empty:
        ProgressView()
      case .failure:
        Image(systemName: "photo")
          .resizable()
          .scaledToFit()
          .foregroundColor(.gray)
      case .success(let image):
        image
          .resizable()
          .scaledToFit()
      @unknown default:
        EmptyView()
      }
    }
    .scaleEffect(viewModel.scale)
    .offset(viewModel.offset)
    .gesture(zoomAndPanGesture)
    .onTapGesture(count: 2) {
      if viewModel.scale > 1 {
        viewModel.resetZoom()
        baseScale = 1
        currentOffset = .zero
      } else {
        withAnimation(.spring()) {
          viewModel.scale = 2
          baseScale = 2
        }
      }
    }
    .accessibilityElement()
    .accessibilityLabel("Preview image")
    .accessibilityHint("Pinch to zoom, drag to pan")
  }

  private var zoomAndPanGesture: some Gesture {
    SimultaneousGesture(
      MagnificationGesture()
        .onChanged { value in
          let newScale = baseScale * value
          viewModel.scale = min(max(newScale, 1), 5)
        }
        .onEnded { _ in
          baseScale = viewModel.scale
          if baseScale <= 1 {
            viewModel.resetZoom()
            baseScale = 1
          }
        },
      DragGesture()
        .onChanged { value in
          if viewModel.scale > 1 {
            viewModel.offset = CGSize(
              width: currentOffset.width + value.translation.width,
              height: currentOffset.height + value.translation.height
            )
          }
        }
        .onEnded { _ in
          currentOffset = viewModel.offset
          if viewModel.scale <= 1 {
            viewModel.resetZoom()
            currentOffset = .zero
          }
        }
    )
  }
}
