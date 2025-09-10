import BottomSheet
import CoreLocation
import SwiftUI
import SwiftUINavigationTransitions

struct PlantDetailView: View {
  @StateObject private var plantManager = PlantManager.shared

  @State private var isExpanded = true
  @State private var showingCreateTaskSheet = false
  @State private var showForm = false

  private func navigateToForm() {
    showForm = true
  }

  var plant: PlantInstance {
    return plantManager.selectedPlant ?? PlantInstance.empty()
  }

  var body: some View {
    NavigationStack {
      List {
        Section("Informasi Tanaman", isExpanded: $isExpanded) {
          RoundedRectangle(cornerRadius: 18)
            .fill(
              LinearGradient(
                colors: [
                  Color.gray.opacity(0.25),
                  Color.gray.opacity(0.15),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              )
            )
            .frame(height: 220)
            .overlay(
              Image(systemName: "photo").font(.system(size: 40))
                .foregroundStyle(.secondary)
            )

          Button {
            print(
              "Koordinat: \(plant.location.latitude ?? 0), \(plant.location.longitude ?? 0)"
            )
            // showingLocationSheet = true
          } label: {
            Label(
              "Koordinat \(plant.location.latitude ?? 0), \(plant.location.longitude ?? 0)",
              systemImage: "mappin.and.ellipse"
            ).foregroundColor(.accentColor)
          }

          Text(plant.name).font(.largeTitle).bold()
          Text(plant.detailLocation ?? "").font(.largeTitle).bold()
        }
        .listRowSeparator(.hidden)
        .listRowBackground(Color(.systemGray6))

        // // Action buttons
        // VStack(spacing: 12) {
        //   Button(action: {
        //     showingPlantConditionSheet = true
        //   }) {
        //     Text("Catat Kondisi")
        //       .font(.headline)
        //       .foregroundStyle(.white)
        //       .frame(maxWidth: .infinity)
        //       .padding(.vertical, 14)
        //   }
        //   .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 16))

        //   Button(action: {

        //   }) {
        //     HStack {
        //       Image(systemName: "info.circle")
        //       Text("Detail Tanaman")
        //         .font(.headline)
        //     }
        //     .foregroundStyle(.primary)
        //     .frame(maxWidth: .infinity)
        //     .padding(.vertical, 14)
        //   }
        //   .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 16))
        // }
        // .padding(.top, 8)

        // // Add more content to demonstrate scrolling
        // VStack(alignment: .leading, spacing: 12) {
        //   Text("Riwayat Perawatan")
        //     .font(.headline)
        //     .foregroundStyle(.secondary)
        //     .padding(.top, 16)

        // ForEach(historyItems, id: \.title) { item in
        //   HStack {
        //     VStack(alignment: .leading, spacing: 4) {
        //       Text(item.title)
        //         .font(.subheadline.weight(.medium))
        //       Text(item.date)
        //         .font(.caption)
        //         .foregroundStyle(.secondary)
        //     }
        //     Spacer()
        //     Image(systemName: "chevron.right")
        //       .font(.caption)
        //       .foregroundStyle(.secondary)
        //   }
        //   .padding(12)
        //   .background(Color.gray.opacity(0.05), in: RoundedRectangle(cornerRadius: 12))
        // }
        // }

        // Additional content to ensure scrolling is needed
        // VStack(alignment: .leading, spacing: 12) {
        //   Text("Catatan Tambahan")
        //     .font(.headline)
        //     .foregroundStyle(.secondary)
        //     .padding(.top, 16)

        //   Text(
        //     "Tanaman ini memerlukan perawatan rutin setiap 2 minggu. Perhatikan kondisi tanah dan pastikan drainase yang baik."
        //   )
        //   .font(.body)
        //   .foregroundStyle(.secondary)
        //   .padding(12)
        //   .background(Color.blue.opacity(0.05), in: RoundedRectangle(cornerRadius: 12))
        // }
      }
      .listStyle(.sidebar)
      .overlay(
        VStack {
          Spacer()
          HStack {
            Button(action: {
              navigateToForm()
            }) {
              Text("Ubah")
                .font(.headline)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.secondary)
            Button(action: {
              showingCreateTaskSheet = true
            }) {
              Text("Catat Kondisi")
                .font(.headline)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.primary)
          }
        }
        .padding()
      )
      .navigationBarTitleDisplayMode(.inline)
      .navigationTransition(.slide)
      .containerBackground(.clear, for: .navigation)
      .scrollContentBackground(.hidden)
      .background(.clear)
      .sheet(isPresented: $showingCreateTaskSheet) {
        CreateTaskView()
      }
      .navigationDestination(isPresented: $showForm) {
        PlantFormView(mode: .update)
      }
    }
  }
}

struct PlantDetailSheet: ViewModifier {
  let positions: [BottomSheetPosition] = [.hidden, .relative(0.9)]

  @State var bottomSheetPosition: BottomSheetPosition
  @Binding var isPresented: Bool

  init(isPresented: Binding<Bool>) {
    self._isPresented = isPresented
    self.bottomSheetPosition = self.positions[0]
  }

  func body(content: Content) -> some View {
    content
      .bottomSheet(
        bottomSheetPosition: $bottomSheetPosition,
        switchablePositions: positions,
      ) {
        PlantDetailView()
      }
      .onDismiss {
        isPresented = false
      }
      .commonModifiers()
      .enableSwipeToDismiss()
      .onChange(of: isPresented) { _, newValue in
        if newValue {
          bottomSheetPosition = positions[1]
        } else {
          bottomSheetPosition = positions[0]
        }
      }
  }
}
extension View {
  func plantDetailSheet(isPresented: Binding<Bool>) -> some View {
    modifier(PlantDetailSheet(isPresented: isPresented))
  }
}
