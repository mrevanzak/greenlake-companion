import SwiftUI

struct CreateTaskSheet: View {
  @Environment(\.dismiss) private var dismiss
  @EnvironmentObject private var plantManager: PlantManager
  @StateObject private var vm = TaskCreationViewModel()

  var body: some View {
    NavigationStack {
      Form {
        Section("Tanaman") {
          Text(plantSummary).foregroundStyle(.primary)
        }
        Section("Detail Tugas") {
          TextField("Judul", text: $vm.title)
          Picker("Tipe", selection: $vm.taskType) {
            ForEach(TaskType.allCases) { Text($0.displayName).tag($0) }
          }
          Picker("Status", selection: $vm.status) {
            ForEach(TaskStatus.allCases) { Text($0.displayName).tag($0) }
          }
          DatePicker("Tenggat", selection: $vm.dueDate, displayedComponents: .date)
          TextEditor(text: $vm.description).frame(minHeight: 120)
        }
      }
      .navigationTitle("Buat Tugas")
      .toolbar {
        ToolbarItem(placement: .cancellationAction) { Button("Batal") { dismiss() } }
        ToolbarItem(placement: .confirmationAction) {
          Button("Simpan") {
            Task { await vm.create(); dismiss() }
          }.disabled(!vm.isValid)
        }
      }
    }
  }

  private var plantSummary: String {
    guard let p = plantManager.selectedPlant else { return "Belum ada tanaman terpilih" }
    return "\(p.name.isEmpty ? "Tanaman" : p.name) • \(p.type.displayName)"
  }
}
