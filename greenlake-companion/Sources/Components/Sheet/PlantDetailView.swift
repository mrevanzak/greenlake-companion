import BottomSheet
import CoreLocation
import SwiftUI
import SwiftUINavigationTransitions

struct PlantDetailView: View {
  @StateObject private var plantManager = PlantManager.shared
  private var taskService = TaskService()
  
  @State private var isExpanded = true
  @State private var showingCreateTaskSheet = false
  @State private var showForm = false
  
  @State private var activeTasks: [PlantTask] = []
  @State private var historyTasks: [PlantTask] = []
  @State private var isLoadingActiveTasks = false
  @State private var isLoadingHistoryTasks = false
  @State private var activeTasksError: Error?
  @State private var historyTasksError: Error?
  
  var previewPlant: PlantInstance? = nil
  init(previewPlant: PlantInstance? = nil) {
    self.previewPlant = previewPlant
  }
  
  private func navigateToForm() {
    showForm = true
  }
  
  var plant: PlantInstance {
    previewPlant ?? plantManager.selectedPlant ?? PlantInstance.empty()
  }
  
  private func fetchTasks() async {
    let plantId = plant.id
    
    guard plantId != UUID() else { return }
    
    isLoadingActiveTasks = true
    do {
      let fetchedActiveTasks = try await taskService.fetchActiveTaskByPlant(id: plantId)
      activeTasks = fetchedActiveTasks
      activeTasksError = nil
    } catch {
      activeTasksError = error
    }
    isLoadingActiveTasks = false
    
    isLoadingHistoryTasks = true
    do {
      let fetchedHistoryTasks = try await taskService.fetchHistoryTaskByPlant(id: plantId)
      historyTasks = fetchedHistoryTasks
      historyTasksError = nil
    } catch {
      historyTasksError = error
    }
    isLoadingHistoryTasks = false
  }
  
  struct TaskCardView: View {
    var task: PlantTask
    
    private func daysLeft(until dueDate: Date) -> Int {
      let calendar = Calendar.current
      let currentDate = Date()
      let components = calendar.dateComponents([.day], from: currentDate, to: dueDate)
      return components.day ?? 0
    }
    
    private func backgroundColor(for dueDate: Date) -> Color {
      let daysLeft = self.daysLeft(until: dueDate)
      
      if daysLeft < 0 {
        return .red
      } else if daysLeft <= 7 {
        return .red
      } else if daysLeft <= 14 {
        return .orange
      } else {
        return .green
      }
    }
    
    var body: some View {
      HStack {
        VStack(alignment: .leading, spacing: 4) {
          Text(task.taskName)
            .font(.headline)
            .foregroundColor(.white)
          
          Text(dateFormatter.string(from: task.dueDate))
            .font(.subheadline)
            .foregroundColor(.white)
        }
        
        Spacer()
        
        VStack(alignment: .trailing, spacing: 4) {
          Text(task.urgency)
            .font(.subheadline)
            .foregroundColor(.white)
          
          Text(task.status)
            .font(.headline)
            .foregroundColor(.white)
        }
      }
      .padding()
      .background(self.backgroundColor(for: task.dueDate))
      .cornerRadius(12)
    }
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
          
          Text(plant.name)
            .font(.largeTitle)
            .bold()
          
          HStack {
            Image(systemName: "ruler")
              .foregroundColor(.secondary)
            Text(String(format: "%.2f", plant.radius ?? 0))
              .font(.system(size: 16))
          }
          
          HStack {
            Image(systemName: "tree")
              .foregroundColor(.secondary)
            Text(plant.type.displayName.capitalized)
              .font(.system(size: 16))
          }
        }
        .padding(.top, 0)
        .listRowSeparator(.hidden)
        .listRowBackground(Color(.clear))
        
        if !activeTasks.isEmpty {
          Section(header: Text("Active Tasks")) {
            ForEach(activeTasks, id: \.id) { task in
              TaskCardView(task: task)
            }
            .listRowSeparator(.hidden)
            .listRowBackground(Color(.clear))
          }
        } else {
          Section(header: Text("Pekerjaan AKtif")) {
            Text("Tidak ada pekerjaan aktif")
              .foregroundColor(.secondary)
          }
          .listRowSeparator(.hidden)
          .listRowBackground(Color(.clear))
        }
        
        if !historyTasks.isEmpty {
          Section(header: Text("Riwayat Pekerjaan")) {
            ForEach(historyTasks, id: \.id) { task in
              TaskCardView(task: task)
                .listRowBackground(Color(.clear))
            }
          }
        } else {
          Section(header: Text("History Tasks")) {
            Text("Tidak ada riwayat pekerjaan")
              .foregroundColor(.secondary)
              .listRowBackground(Color(.clear))
          }
        }
      }
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
      .hideNavigationBar()
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
      .onChange(of: plant) { _ in
        Task {
          await fetchTasks()
        }
      }
      // Initial fetch for tasks
      .task {
        await fetchTasks()
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

#Preview {
  PlantDetailView(previewPlant: PlantInstance(
    id: UUID(uuidString: "3bda81e6-207e-408d-a805-ece88929057c")!,
    type: PlantType.bush,
    name: "Lidah Mertua",
    location: CLLocationCoordinate2D(latitude: -6.2, longitude: 106.8),
    detailLocation: "Ruang Tamu",
    createdAt: Date(),
    updatedAt: Date(),
  ))
}

extension View {
  func plantDetailSheet(isPresented: Binding<Bool>) -> some View {
    modifier(PlantDetailSheet(isPresented: isPresented))
  }
}
