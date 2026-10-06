//
//  TendiesView.swift
//  AirCard-iOS
//
//  Dopamine-styled .tendies wallpaper manager.
//

import SwiftUI
import UniformTypeIdentifiers

struct TendiesView: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var showFilePicker = false
    @State private var selectedDetailItem: TendieItem? = nil
    @State private var isNeoSpringing = false

    private var selectedCount: Int { vm.tendieItems.filter { $0.isSelected }.count }
    private var selectedAll: Bool { !vm.tendieItems.isEmpty && vm.tendieItems.allSatisfy { $0.isSelected } }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    if let err = vm.errorMessage {
                        errorBanner(err)
                    }
                    importCard
                    optionsCard

                    if vm.tendieItems.isEmpty {
                        emptyCard
                    } else {
                        galleryCard
                    }

                    actionCard

                    if !vm.tendiesFlashLog.isEmpty {
                        CompactLogView(title: "Flash Log (\(vm.tendiesFlashLog.count))",
                                       lines: vm.tendiesFlashLog,
                                       onClear: { vm.tendiesFlashLog.removeAll() })
                            .padding(14).dopeCard(cornerRadius: 14)
                    }

                    Spacer(minLength: 40)
                }
                .padding(.vertical).padding(.horizontal)
            }
            .scrollContentBackground(.hidden).background(Color.clear)
            .navigationTitle("Wallpapers")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showFilePicker = true } label: {
                        Image(systemName: "plus").font(.headline)
                    }
                }
            }
            .sheet(isPresented: $showFilePicker) {
                TendiesDocumentPickerView { urls in
                    Task { await vm.importTendieFiles(urls: urls) }
                }
            }
            .sheet(item: $selectedDetailItem) { item in
                TendieDetailSheet(item: item)
            }
            .onAppear {
                vm.isNeoSpringing = false
                isNeoSpringing = false
                vm.showSuccessAlert = false
                vm.successAlertMessage = ""
                vm.scanDocumentsForTendies()
            }
            .task {
                if vm.posterBoardContainer.isEmpty {
                    await vm.autoDetectPosterBoardContainer(silent: true)
                }
            }
            .overlay {
                if isNeoSpringing || vm.isNeoSpringing {
                    ZStack {
                        Color.black.ignoresSafeArea()
                        NeoSpringView().brightness(-1.0).ignoresSafeArea()
                    }
                }
            }
        }
    }

    private func errorBanner(_ err: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.red)
            Text(err).font(.caption).foregroundStyle(.red)
            Spacer()
            Button { vm.errorMessage = nil } label: {
                Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
            }.buttonStyle(.plain)
        }
        .padding(12).dopeCard(cornerRadius: 14)
    }

    private var importCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button { showFilePicker = true } label: {
                HStack(spacing: 8) {
                    Spacer()
                    Image(systemName: "doc.badge.plus")
                    Text(vm.tendieItems.isEmpty ? "Choose .tendies from Files…" : "Import More Wallpapers…")
                    Spacer()
                }
                .font(.headline).frame(height: 48)
            }.buttonStyle(.borderedProminent)

            Text(vm.posterBoardContainer.isEmpty
                 ? "PosterBoard container will be auto-detected on flash."
                 : "Target: PosterBoard container detected ✅")
                .font(.caption2).foregroundStyle(.secondary)
        }
        .padding(14).dopeCard(cornerRadius: 16)
    }

    private var optionsCard: some View {
        Toggle(isOn: $vm.resetPBProtections) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Force PosterBoard Cache Refresh").font(.subheadline.weight(.medium))
                Text("Resets file protections so iOS re-indexes wallpapers immediately")
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
        .padding(14).dopeCard(cornerRadius: 16)
    }

    private var emptyCard: some View {
        VStack(spacing: 10) {
            Image(systemName: "photo.stack").font(.system(size: 32)).foregroundStyle(.secondary)
            Text("No .tendies wallpapers loaded yet").font(.subheadline).foregroundStyle(.secondary)
            Text("Tap 'Choose .tendies from Files' or drop wallpapers into On My iPhone › Andromeda.")
                .font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 20)
        .padding(14).dopeCard(cornerRadius: 16)
    }

    private var galleryCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("\(vm.tendieItems.count) Wallpapers Imported")
                    .font(.caption.bold()).foregroundStyle(.secondary)
                Spacer()
                Button(selectedAll ? "Deselect All" : "Select All") {
                    let target = !selectedAll
                    for i in 0..<vm.tendieItems.count { vm.tendieItems[i].isSelected = target }
                }.font(.caption)
            }
            ForEach($vm.tendieItems) { $item in
                TendieRowView(item: $item) {
                    selectedDetailItem = item
                } onDelete: {
                    vm.deleteTendie(item: item)
                }
                if item.id != vm.tendieItems.last?.id { Divider() }
            }
        }
        .padding(14).dopeCard(cornerRadius: 16)
    }

    private var actionCard: some View {
        VStack(spacing: 12) {
            if case .running = vm.tendiesFlashPhase {
                HStack(spacing: 10) {
                    ProgressView()
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Flashing Wallpapers…").font(.subheadline.bold())
                        ProgressView(value: vm.tendiesFlashProgress)
                    }
                }.padding(.vertical, 4)
            } else {
                Button {
                    Task { await vm.flashSelectedTendies() }
                } label: {
                    HStack(spacing: 8) {
                        Spacer()
                        Image(systemName: "sparkles")
                        Text("Flash \(selectedCount) Wallpaper\(selectedCount == 1 ? "" : "s")")
                        Spacer()
                    }.font(.headline).frame(height: 48)
                }.buttonStyle(.borderedProminent).disabled(selectedCount == 0)
            }

            Button {
                vm.isNeoSpringing = true
                isNeoSpringing = true
                RespringHelper.triggerNeoSpring()
            } label: {
                Label("Respring (NeoSpring)", systemImage: "bolt.fill")
                    .font(.headline).frame(maxWidth: .infinity).frame(height: 48)
            }.buttonStyle(.bordered)
        }
        .padding(14).dopeCard(cornerRadius: 16)
    }
}

// MARK: - Tendie Row View

struct TendieRowView: View {
    @Binding var item: TendieItem
    let onInspect: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Toggle("", isOn: $item.isSelected).labelsHidden()

            if let imgData = item.previewImageData, let uiImg = UIImage(data: imgData) {
                Image(uiImage: uiImg).resizable().aspectRatio(contentMode: .fill)
                    .frame(width: 44, height: 60).cornerRadius(6).clipped()
            } else {
                RoundedRectangle(cornerRadius: 6)
                    .fill(.ultraThinMaterial)
                    .frame(width: 44, height: 60)
                    .overlay { Image(systemName: item.posterType.systemIcon).foregroundStyle(.secondary) }
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(item.name).font(.subheadline.bold()).lineLimit(1)
                HStack(spacing: 6) {
                    Text(item.posterType.rawValue).font(.caption2.bold())
                    Text("•").font(.caption2).foregroundStyle(.secondary)
                    Text("\(item.descriptorCount) item\(item.descriptorCount == 1 ? "" : "s")")
                        .font(.caption2).foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button { onInspect() } label: {
                Image(systemName: "info.circle").frame(width: 32, height: 32).contentShape(Rectangle())
            }.buttonStyle(.borderless)

            Button(role: .destructive) { onDelete() } label: {
                Image(systemName: "trash").frame(width: 32, height: 32).contentShape(Rectangle())
            }.buttonStyle(.borderless)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Detail Sheet

struct TendieDetailSheet: View {
    let item: TendieItem
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    if let imgData = item.previewImageData, let uiImg = UIImage(data: imgData) {
                        Image(uiImage: uiImg)
                            .resizable().aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity, maxHeight: 300)
                            .cornerRadius(12)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        detailRow("Name", item.name)
                        detailRow("File Name", item.fileName)
                        detailRow("Type", item.posterType.rawValue)
                        detailRow("Descriptors", "\(item.descriptorCount)")
                        detailRow("Target Extension", item.posterType.extensionBundleId)
                        detailRow("Format", item.isContainer ? "App Container" : "Descriptor Archive")
                        if item.unsafeContainer { detailRow("Warning", "Contains SQLite database") }
                    }
                    .padding(14).dopeCard(cornerRadius: 14)
                }
                .padding()
            }
            .navigationTitle(item.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) { Button("Done") { dismiss() } }
            }
        }
    }

    private func detailRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title).font(.subheadline).foregroundStyle(.secondary)
            Spacer()
            Text(value).font(.subheadline.bold()).lineLimit(1).truncationMode(.middle)
        }
    }
}

// MARK: - Document Picker

struct TendiesDocumentPickerView: UIViewControllerRepresentable {
    let onPick: ([URL]) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        var contentTypes: [UTType] = []
        if let customType = UTType("com.andromeda.tendies") { contentTypes.append(customType) }
        if let extType = UTType(filenameExtension: "tendies") { contentTypes.append(extType) }
        contentTypes.append(contentsOf: [.archive, .zip, .data, .item])

        let picker = UIDocumentPickerViewController(forOpeningContentTypes: contentTypes, asCopy: true)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = true
        return picker
    }
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: TendiesDocumentPickerView
        init(_ parent: TendiesDocumentPickerView) { self.parent = parent }
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard !urls.isEmpty else { return }
            parent.onPick(urls); parent.dismiss()
        }
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) { parent.dismiss() }
    }
}