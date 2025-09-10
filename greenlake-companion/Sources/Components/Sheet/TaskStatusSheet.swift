//
//  TaskStatusSheet.swift
//  greenlake-companion
//
//  Created by Akmal Ariq on 08/09/25.
//

import SwiftUI
import PhotosUI
import UIKit
import Combine

struct TaskStatusSheet: View {
  // MARK: - Dependencies
  @Environment(\.dismiss) private var dismiss
  @StateObject private var vm: TaskStatusViewModel

  // MARK: - Local UI State
  @State private var pickerItems: [PhotosPickerItem] = []
  @FocusState private var noteFocused: Bool
  @State private var showErrorAlert = false
  @State private var errorMessage = ""

  private let allowedStatuses: [String]

  // MARK: - Init
  init(
    taskId: UUID,
    service: TaskServiceProtocol = TaskService(),
    allowedStatuses: [String] = ["Diajukan", "Aktif", "Diperiksa", "Selesai", "Terdenda", "Dialihkan"]
  ) {
    _vm = StateObject(wrappedValue: TaskStatusViewModel(taskId: taskId, service: service))
    self.allowedStatuses = allowedStatuses
  }

  // MARK: - Body
  var body: some View {
    NavigationStack {
      Form {
        statusSection
        noteSection
        photosSection
      }
      .navigationTitle("Update Status")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") { dismiss() }
            .keyboardShortcut(.cancelAction)
        }
        ToolbarItem(placement: .confirmationAction) {
          Button {
            Task { await submit() }
          } label: {
            if isSubmitting {
              ProgressView().controlSize(.regular)
            } else {
              Text("Save").fontWeight(.semibold)
            }
          }
          .disabled(!vm.canSubmit || isSubmitting)
          .keyboardShortcut(.defaultAction)
          .accessibilityLabel("Simpan")
          .accessibilityHint("Kirim status, catatan, dan foto yang dipilih")
        }
      }
      .interactiveDismissDisabled(isSubmitting)
      .presentationDetents([.medium, .large])
      .presentationDragIndicator(.visible)
      .onReceive(vm.$submitState) { newValue in
        switch newValue {
        case .success:
          dismiss()
        case .failure(let msg):
          errorMessage = msg
          showErrorAlert = true
        default:
          break
        }
      }
      .alert("Gagal Memperbarui", isPresented: $showErrorAlert) {
        Button("OK", role: .cancel) { vm.submitState = .idle }
      } message: {
        Text(errorMessage)
      }
      .toolbar {
        // keyboard toolbar to dismiss
        ToolbarItemGroup(placement: .keyboard) {
          Spacer()
          Button("Done") { noteFocused = false }
        }
      }
      .onAppear {
        if vm.status.isEmpty {
          vm.status = allowedStatuses.first ?? ""
          vm.validate()
        }
      }
    }
  }

  // MARK: - Sections

  @ViewBuilder private var statusSection: some View {
    Section {
      Picker("Status", selection: $vm.status) {
        ForEach(allowedStatuses, id: \.self) { status in
          Text(status).tag(status)
        }
      }
      .pickerStyle(.menu)
      .onChange(of: vm.status) { _ in vm.validate() }
      .accessibilityLabel("Pilih status tugas")
      .accessibilityHint("Ketuk untuk memilih status baru")

      if vm.status.isEmpty {
        Text("Status diperlukan.")
          .font(.footnote)
          .foregroundColor(.red) // simpler than .foregroundStyle(.red)
          .accessibilityHidden(true)
      }
    } header: {
      Text("Status")
    } footer: {
      Text("Pilih status yang paling sesuai dengan kondisi terbaru pekerjaan.")
    }
  }

  @ViewBuilder private var noteSection: some View {
    Section {
      ZStack(alignment: .topLeading) {
        if vm.note.isEmpty {
          Text("Catatan (opsional)")
            .foregroundColor(.secondary)
            .padding(.top, 8)
            .padding(.leading, 5)
            .accessibilityHidden(true)
        }
        TextEditor(text: $vm.note)
          .frame(minHeight: 120)
          .focused($noteFocused)
          .accessibilityLabel("Catatan")
          .accessibilityHint("Tambahkan konteks atau informasi tambahan")
      }
    } header: {
      Text("Catatan")
    } footer: {
      Text("Catatan akan dikirim bersama pembaruan status.")
    }
  }

  @ViewBuilder private var photosSection: some View {
    Section {
      PhotosPicker(
        selection: $pickerItems,
        maxSelectionCount: 10,
        matching: .images
      ) {
        Label("Pilih Foto", systemImage: "photo.on.rectangle.angled")
      }
      .onChange(of: pickerItems) { newItems in
        Task { await loadImages(from: newItems) }
      }

      if !vm.selectedImages.isEmpty {
        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 12) {
            ForEach(vm.selectedImages.indices, id: \.self) { idx in
              photoThumb(image: vm.selectedImages[idx], index: idx)
            }
          }
          .padding(.vertical, 6)
        }
      }
    } header: {
      Text("Foto (Opsional)")
    } footer: {
      Text("Tambahkan foto pendukung. Anda dapat memilih hingga 10 foto.")
    }
  }

  @ViewBuilder
  private func photoThumb(image: UIImage, index: Int) -> some View {
    ZStack(alignment: .topTrailing) {
      Image(uiImage: image)
        .resizable()
        .scaledToFill()
        .frame(width: 96, height: 96)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
          RoundedRectangle(cornerRadius: 10, style: .continuous)
            .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        )
        .accessibilityLabel("Foto terpilih \(index + 1)")
        .accessibilityHint("Geser untuk melihat foto lain")

      Button(role: .destructive) {
        vm.removeImage(at: index)
      } label: {
        Image(systemName: "xmark.circle.fill")
          .font(.title3)
          .foregroundColor(.secondary)
          .background(.ultraThinMaterial, in: Circle())
          .contentShape(Circle())
      }
      .offset(x: 6, y: -6)
      .accessibilityLabel("Hapus foto \(index + 1)")
    }
  }

  // MARK: - Helpers

  private var isSubmitting: Bool {
    if case .submitting = vm.submitState { return true } else { return false }
  }

  private func submit() async { await vm.submit() }

  @MainActor
  private func loadImages(from items: [PhotosPickerItem]) async {
    var images: [UIImage] = []
    images.reserveCapacity(items.count)

    for item in items {
      // Load Data (Transferable) then construct UIImage
      if let data = try? await item.loadTransferable(type: Data.self),
         let img = UIImage(data: data) {
        images.append(img)
      }
    }

    vm.addImages(images)
  }
}
