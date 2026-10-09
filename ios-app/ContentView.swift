import SwiftUI
import UIKit
import PhotosUI
import UniformTypeIdentifiers

// MARK: - Helpers

func logLineColor(_ line: String) -> Color {
    if line.contains("✅") || line.contains("🎉") { return .green }
    if line.contains("❌") { return .red }
    if line.contains("⚠️") { return .orange }
    return .secondary
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Theme Picker

struct ThemePickerBar: View {
    @AppStorage("andromeda.theme") private var themeRaw: String = AppTheme.emerald.rawValue
    private var current: AppTheme { AppTheme(rawValue: themeRaw) ?? .emerald }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(AppTheme.allCases) { theme in
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) { themeRaw = theme.rawValue }
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    } label: {
                        HStack(spacing: 8) {
                            Circle().fill(theme.accent).frame(width: 14, height: 14)
                            Text(theme.rawValue)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(current == theme ? .primary : .secondary)
                        }
                        .padding(.horizontal, 14).padding(.vertical, 9)
                        .background(.ultraThinMaterial,
                                    in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(current == theme ? theme.accent.opacity(0.8) : Color.clear, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 4)
        }
    }
}

// MARK: - Main Menu Button

struct DopamineMenuButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            .padding(16)
            .background(.ultraThinMaterial,
                        in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Credits Sheet

struct CreditsSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    VStack(spacing: 8) {
                        Image(systemName: "sparkles").font(.system(size: 48))
                        Text("Andromeda").font(.title2.bold())
                        Text("Apple Wallet Skins & Passcode Themes for iOS 18+")
                            .font(.caption).foregroundStyle(.secondary).multilineTextAlignment(.center)
                    }.padding(.top, 12)

                    VStack(alignment: .leading, spacing: 10) {
                        Label("Lead Developer", systemImage: "crown.fill")
                            .font(.caption.bold().uppercaseSmallCaps())
                        Text("@moondevvv").font(.headline.bold())
                    }
                    .padding(14)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 12) {
                        techRow(icon: "bolt.shield.fill", title: "Core Exploit", subtitle: "airlift (AirTraffic sandbox escape)")
                        Divider()
                        techRow(icon: "gearshape.2.fill", title: "SpringBoard", subtitle: "EscapeEngine (sandbox_extension_issue_file)")
                        Divider()
                        techRow(icon: "lock.shield.fill", title: "Passcode Themes", subtitle: ".passthm standard")
                        Divider()
                        techRow(icon: "bolt.fill", title: "NeoSpring & PosterBoard", subtitle: ".tendies wallpapers")
                    }
                    .padding(14)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .padding(.horizontal)

                    Spacer(minLength: 20)
                }
            }
            .navigationTitle("Credits")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }.bold()
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func techRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon).font(.title3)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.bold())
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Pairing Guide

struct PairingGuideSheet: View {
    @Environment(\.dismiss) private var dismiss
    var onImportTapped: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Where to find your pairing file").font(.title2.bold())
                    Text("Andromeda imports pairing files exported by SideStore, LiveContainer, iLoader, or PC.")
                        .font(.subheadline).foregroundStyle(.secondary)

                    guideCard(title: "SideStore", icon: "app.badge.checkmark.fill",
                              body: "On My iPhone › SideStore › ALTPairingFile.mobiledevicepairing")
                    guideCard(title: "LiveContainer", icon: "shippingbox.fill",
                              body: "On My iPhone › LiveContainer › SideStore › Documents › ALTPairingFile.mobiledevicepairing")
                    guideCard(title: "iLoader / Jitterbug / AltStore", icon: "arrow.down.doc.fill",
                              body: "Export from the app, or jitterbugpair on PC/Mac.")
                    guideCard(title: "Manual Drop", icon: "folder.fill",
                              body: "Files app › On My iPhone › Andromeda")

                    Button {
                        dismiss(); onImportTapped()
                    } label: {
                        Label("Import Pairing File Now", systemImage: "square.and.arrow.down.fill")
                            .font(.headline).frame(maxWidth: .infinity).frame(height: 48)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
            .navigationTitle("Pairing Guide")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) { Button("Done") { dismiss() }.bold() }
            }
        }
    }

    private func guideCard(title: String, icon: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) { Image(systemName: icon).font(.title3); Text(title).font(.headline.bold()) }
            Text(body).font(.footnote).foregroundStyle(.secondary)
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

// MARK: - Compact Log

struct CompactLogView: View {
    let title: String
    let lines: [String]
    var onClear: (() -> Void)? = nil
    @State private var copied = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title).font(.caption.bold()).foregroundStyle(.secondary)
                Spacer()
                if let onClear = onClear, !lines.isEmpty {
                    Button(action: onClear) { Image(systemName: "trash").font(.caption) }
                        .buttonStyle(.borderless).padding(.trailing, 6)
                }
                Button {
                    UIPasteboard.general.string = lines.joined(separator: "\n")
                    copied = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { copied = false }
                } label: {
                    Label(copied ? "Copied" : "Copy", systemImage: copied ? "checkmark" : "doc.on.doc")
                        .font(.system(size: 11, weight: .bold))
                        .padding(.horizontal, 9).padding(.vertical, 4)
                        .background(.ultraThinMaterial,
                                    in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                }.buttonStyle(.borderless)
            }
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 2) {
                        ForEach(Array(lines.enumerated()), id: \.offset) { idx, line in
                            Text(line)
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundStyle(logLineColor(line))
                                .textSelection(.enabled)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .id(idx)
                        }
                    }.padding(8)
                }
                .frame(maxHeight: 180)
                .background(.ultraThinMaterial,
                            in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .onChange(of: lines.count) { _, _ in
                    if !lines.isEmpty { proxy.scrollTo(lines.count - 1, anchor: .bottom) }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Document Picker

struct DocumentPickerView: UIViewControllerRepresentable {
    let allowedContentTypes: [UTType]
    let onPick: (URL) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: allowedContentTypes, asCopy: true)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPickerView
        init(_ parent: DocumentPickerView) { self.parent = parent }
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            let stop = url.startAccessingSecurityScopedResource()
            defer { if stop { url.stopAccessingSecurityScopedResource() } }
            parent.onPick(url); parent.dismiss()
        }
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) { parent.dismiss() }
    }
}

// MARK: - Root (Dopamine-style)

struct ContentView: View {
    @EnvironmentObject var vm: AppViewModel
    @AppStorage("andromeda.theme") private var themeRaw: String = AppTheme.emerald.rawValue
    private var theme: AppTheme { AppTheme(rawValue: themeRaw) ?? .emerald }

    @State private var showCredits = false
    @State private var activeSheet: ActiveSheet?

    enum ActiveSheet: Identifiable {
        case wallet, passcode, wallpapers, jit, settings, misc, springboard
        var id: String {
            switch self {
            case .wallet: return "wallet"
            case .passcode: return "passcode"
            case .wallpapers: return "wallpapers"
            case .jit: return "jit"
            case .settings: return "settings"
            case .misc: return "misc"
            case .springboard: return "springboard"
            }
        }
    }

    var body: some View {
        ZStack {
            theme.backgroundGradient.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    // Header
                    VStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 40))
                            .foregroundStyle(theme.accent)
                        Text("Andromeda")
                            .font(.largeTitle.bold())
                        Text("@moondevvv")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 8)

                    ThemePickerBar().padding(.horizontal)

                    // Main Action
                    Button {
                        if vm.canFlashCards { vm.flashCards() }
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "bolt.fill").font(.title3)
                            Text(vm.canFlashCards ? "Flash Wallet Cards" : "Pair to Start")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .foregroundStyle(.white)
                        .background(theme.accent.opacity(vm.canFlashCards ? 1.0 : 0.4))
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .disabled(!vm.canFlashCards)
                    .padding(.horizontal)

                    if !vm.log.isEmpty {
                        CompactLogView(title: "Activity Log (\(vm.log.count))",
                                       lines: Array(vm.log.suffix(5)),
                                       onClear: { vm.log.removeAll() })
                            .padding(.horizontal)
                    }

                    // Menu
                    VStack(spacing: 10) {
                        DopamineMenuButton(icon: "creditcard.fill", title: "Wallet Cards",
                                           subtitle: "\(vm.cards.count) cards") {
                            activeSheet = .wallet
                        }
                        DopamineMenuButton(icon: "gearshape.2.fill", title: "SpringBoard",
                                           subtitle: "Carrier, respring, keys") {
                            activeSheet = .springboard
                        }
                        DopamineMenuButton(icon: "lock.circle.fill", title: "Passcode Themes",
                                           subtitle: "Custom keypad") {
                            activeSheet = .passcode
                        }
                        DopamineMenuButton(icon: "photo.stack.fill", title: "Wallpapers",
                                           subtitle: "\(vm.tendieItems.count) .tendies") {
                            activeSheet = .wallpapers
                        }
                        DopamineMenuButton(icon: "bolt.fill", title: "JIT Enabler",
                                           subtitle: "Just-in-Time") {
                            activeSheet = .jit
                        }
                        DopamineMenuButton(icon: "gearshape.fill", title: "Settings",
                                           subtitle: "Theme & UI") {
                            activeSheet = .settings
                        }
                        DopamineMenuButton(icon: "square.grid.2x2.fill", title: "Misc",
                                           subtitle: "Sandbox paths, system") {
                            activeSheet = .misc
                        }
                        DopamineMenuButton(icon: "info.circle.fill", title: "Credits",
                                           subtitle: "About Andromeda") {
                            showCredits = true
                        }
                    }
                    .padding(.horizontal)

                    Spacer(minLength: 40)
                }
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showCredits) { CreditsSheet() }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .wallet:
                NavigationStack { WalletCardsTab()
                    .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("Done") { activeSheet = nil }.bold() } } }
            case .springboard:
                NavigationStack { SpringBoardView()
                    .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("Done") { activeSheet = nil }.bold() } } }
            case .passcode:
                NavigationStack { PasscodeThemeTab()
                    .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("Done") { activeSheet = nil }.bold() } } }
            case .wallpapers:
                NavigationStack { TendiesView()
                    .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("Done") { activeSheet = nil }.bold() } } }
            case .jit:
                NavigationStack { JITEnablerView()
                    .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("Done") { activeSheet = nil }.bold() } } }
            case .settings:
                NavigationStack { SettingsView()
                    .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("Done") { activeSheet = nil }.bold() } } }
            case .misc:
                NavigationStack { MiscView()
                    .toolbar { ToolbarItem(placement: .navigationBarTrailing) { Button("Done") { activeSheet = nil }.bold() } } }
            }
        }
        .alert("Notice", isPresented: Binding(
            get: { vm.errorMessage != nil },
            set: { if !$0 { vm.errorMessage = nil } }
        )) { Button("OK") { vm.errorMessage = nil } } message: { Text(vm.errorMessage ?? "") }
        .alert("Success! 🎉", isPresented: $vm.showSuccessAlert) {
            Button("OK") {}
        } message: { Text(vm.successAlertMessage) }
        .sheet(isPresented: $vm.showShareSheet) {
            if let url = vm.exportedThemeURL { ShareSheet(items: [url]) }
        }
    }
}

// MARK: - Wallet Cards

struct WalletCardView: View {
    let card: CardItem
    let cardIndex: Int
    let onToggleSelected: (Bool) -> Void
    let onPickImage: () -> Void
    let onClearImage: () -> Void
    let onDelete: () -> Void
    @State private var copied = false

    var body: some View {
        VStack(spacing: 12) {
            GeometryReader { geo in
                let width = geo.size.width
                let height = width / 1.586
                ZStack {
                    if let img = card.uiImage {
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: img).resizable().scaledToFill()
                                .frame(width: width, height: height)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            Button(action: onClearImage) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundStyle(.white.opacity(0.95))
                                    .background(Circle().fill(Color.black.opacity(0.55)))
                            }.buttonStyle(.plain).padding(10)
                        }
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16, style: .continuous).fill(.ultraThinMaterial)
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.white.opacity(0.18), style: StrokeStyle(lineWidth: 1.2, dash: [6, 4]))
                            VStack(spacing: 8) {
                                Image(systemName: "photo.badge.plus").font(.system(size: 32))
                                Text("Assign Card Skin").font(.subheadline.bold())
                                Text("Tap to choose photo").font(.caption2).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .frame(width: width, height: height)
                .contentShape(Rectangle()).onTapGesture { onPickImage() }
            }.aspectRatio(1.586, contentMode: .fit)

            HStack(spacing: 8) {
                Toggle("", isOn: Binding(get: { card.isSelected }, set: { onToggleSelected($0) })).labelsHidden()
                Text("Card #\(cardIndex + 1)").font(.system(size: 13, weight: .semibold))
                HStack(spacing: 4) {
                    Text(card.id.prefix(8) + "…" + card.id.suffix(6))
                        .font(.system(size: 11, design: .monospaced)).foregroundStyle(.secondary)
                    Button {
                        UIPasteboard.general.string = card.id
                        copied = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { copied = false }
                    } label: {
                        Image(systemName: copied ? "checkmark.circle.fill" : "doc.on.doc").font(.system(size: 10))
                    }.buttonStyle(.plain)
                }
                .padding(.horizontal, 8).padding(.vertical, 4)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                Spacer()
                Button(role: .destructive, action: onDelete) {
                    Image(systemName: "trash").font(.system(size: 14)).frame(width: 32, height: 32)
                }.buttonStyle(.plain)
            }
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

struct WalletCardsTab: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var newHashText = ""
    @State private var showAddSheet = false
    enum ActiveCardPicker: Identifiable {
        case singleCard(String), bulkAll
        var id: String { switch self { case .singleCard(let id): return id; case .bulkAll: return "bulk" } }
    }
    @State private var activePicker: ActiveCardPicker? = nil
    @State private var showSourceDialog = false
    @State private var isPhotosPickerPresented = false
    @State private var isDocumentPickerPresented = false
    private struct CropRequest: Identifiable { let id = UUID(); let image: UIImage; let target: ActiveCardPicker }
    @State private var pendingCrop: CropRequest? = nil
    @State private var cropRequest: CropRequest? = nil
    @State private var photoLoadFailed = false
    @State private var pendingLoadError = false
    @State private var cropAccepted = false

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                if vm.cards.isEmpty { emptyState }
                else {
                    ForEach(vm.cards, id: \.id) { card in
                        let idx = vm.cards.firstIndex(where: { $0.id == card.id }) ?? 0
                        WalletCardView(
                            card: card, cardIndex: idx,
                            onToggleSelected: { vm.setCardSelected(id: card.id, selected: $0) },
                            onPickImage: { activePicker = .singleCard(card.id); showSourceDialog = true },
                            onClearImage: { vm.clearCardImage(for: card.id) },
                            onDelete: { vm.deleteCard(id: card.id) }
                        )
                    }
                    if !vm.cardFlashLog.isEmpty {
                        CompactLogView(title: "Flash Log", lines: vm.cardFlashLog,
                                       onClear: { vm.cardFlashLog.removeAll() })
                            .padding(14)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                }
                Spacer(minLength: 40)
            }.padding(.vertical).padding(.horizontal)
        }
        .scrollContentBackground(.hidden)
        .navigationTitle("Wallet (\(vm.cards.count))")
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { vm.toggleCardScanning() } label: {
                    Label(vm.isScanningCards ? "Stop" : "Scan",
                          systemImage: vm.isScanningCards ? "stop.circle.fill" : "wave.3.left.circle")
                        .font(.subheadline.bold())
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button { showAddSheet = true } label: { Label("Add Card", systemImage: "plus") }
                    if !vm.cards.isEmpty {
                        Button { vm.selectAllCards(true) } label: { Label("Select All", systemImage: "checkmark.circle") }
                        Button { vm.selectAllCards(false) } label: { Label("Deselect All", systemImage: "circle") }
                        Divider()
                        Button(role: .destructive) { vm.clearAllCards() } label: { Label("Clear All", systemImage: "trash") }
                    }
                } label: { Image(systemName: "ellipsis.circle").font(.title3) }
            }
            ToolbarItem(placement: .navigationBarTrailing) { flashButton }
        }
        .sheet(isPresented: $showAddSheet) {
            AddCardSheet(hashText: $newHashText) {
                vm.addCardHash(newHashText); newHashText = ""; showAddSheet = false
            }
        }
        .confirmationDialog("Choose Image Source", isPresented: $showSourceDialog, titleVisibility: .visible) {
            Button { isPhotosPickerPresented = true } label: { Label("Photo Library", systemImage: "photo.on.rectangle") }
            Button { isDocumentPickerPresented = true } label: { Label("Choose from Files…", systemImage: "folder") }
            Button("Cancel", role: .cancel) { activePicker = nil }
        }
        .sheet(isPresented: $isPhotosPickerPresented, onDismiss: { activePicker = nil }) {
            if let target = activePicker { CardPhotoPicker { assignImage($0, to: target) } }
        }
        .sheet(isPresented: $isDocumentPickerPresented, onDismiss: presentPendingCrop) {
            DocumentPickerView(allowedContentTypes: [.image, .png, .jpeg, .heic,
                UTType(filenameExtension: "webp") ?? .image,
                UTType(filenameExtension: "tiff") ?? .image
            ]) { url in
                guard let picker = activePicker else { return }
                if let data = try? Data(contentsOf: url),
                   let image = ImageEngine.safeImageFromData(data, maxDimension: 2560) {
                    pendingCrop = CropRequest(image: image, target: picker)
                } else { pendingLoadError = true }
                activePicker = nil
            }
        }
        .sheet(item: $cropRequest, onDismiss: { if !cropAccepted { isDocumentPickerPresented = true } }) { request in
            CardPhotoCropView(image: request.image) { croppedImage in
                cropAccepted = true; assignImage(croppedImage, to: request.target); activePicker = nil
            }
        }
        .alert("Couldn't Load Photo", isPresented: $photoLoadFailed) { Button("OK", role: .cancel) {} }
    }

    private func assignImage(_ image: UIImage, to target: ActiveCardPicker) {
        switch target {
        case .singleCard(let id): vm.setCardImage(for: id, image: image)
        case .bulkAll: vm.setSkinForAllCards(image: image)
        }
    }
    private func presentPendingCrop() {
        guard !isPhotosPickerPresented, !isDocumentPickerPresented else { return }
        if let request = pendingCrop { pendingCrop = nil; cropAccepted = false; activePicker = request.target; cropRequest = request }
        else if pendingLoadError { pendingLoadError = false; photoLoadFailed = true }
    }

    @ViewBuilder private var flashButton: some View {
        Button { vm.flashCards() } label: {
            HStack(spacing: 6) {
                if case .running = vm.cardFlashPhase { ProgressView().scaleEffect(0.75); Text("Flashing…") }
                else { Image(systemName: "bolt.fill"); Text("Flash") }
            }.font(.system(size: 13, weight: .semibold))
        }
        .buttonStyle(.borderedProminent)
        .disabled(!vm.canFlashCards || vm.cardFlashPhase == .running)
    }

    private var emptyState: some View {
        VStack(spacing: 18) {
            Image(systemName: "creditcard.viewfinder").font(.system(size: 56))
            Text("No Cards Detected").font(.title3.bold())
            VStack(alignment: .leading, spacing: 10) {
                Text("1. Tap **Scan** above.")
                Text("2. Double-click Side button (Apple Pay).")
                Text("3. Tap your card.")
            }.font(.subheadline).foregroundStyle(.secondary)
                .padding(16)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }.padding(.top, 40)
    }
}

struct AddCardSheet: View {
    @Binding var hashText: String
    let onAdd: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Card Hash") {
                    TextField("Paste hash…", text: $hashText, axis: .vertical)
                        .font(.system(.body, design: .monospaced))
                        .autocorrectionDisabled().textInputAutocapitalization(.never)
                        .lineLimit(4...8)
                }
            }
            .navigationTitle("Add Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") { onAdd() }
                        .disabled(hashText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty).bold()
                }
            }
        }
    }
}

// MARK: - Passcode Tab

struct PasscodeThemeTab: View {
    @EnvironmentObject var vm: AppViewModel
    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                Picker("Mode", selection: $vm.passcodeMode) {
                    ForEach(CreatorMode.allCases) { m in Text(m.rawValue).tag(m) }
                }.pickerStyle(.segmented)

                if vm.passcodeMode == .applyTheme { ApplyThemeSection() }
                else { ThemeCreatorSection() }

                if !vm.passthmFlashLog.isEmpty {
                    CompactLogView(title: "Flash Log", lines: vm.passthmFlashLog,
                                   onClear: { vm.passthmFlashLog.removeAll() })
                        .padding(14)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                Spacer(minLength: 40)
            }.padding(.vertical).padding(.horizontal)
        }
        .scrollContentBackground(.hidden)
        .navigationTitle("Passcode")
        .toolbarBackground(.hidden, for: .navigationBar)
    }
}

struct ApplyThemeSection: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var showDocumentPicker = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !vm.documentsThemes.isEmpty {
                Text("Themes in App Folder").font(.caption.bold()).foregroundStyle(.secondary)
                ForEach(vm.documentsThemes, id: \.self) { file in
                    HStack {
                        Image(systemName: "paintpalette.fill")
                        Text(file).font(.system(size: 13, design: .monospaced))
                        Spacer()
                        Button("Load") { vm.loadPassthmFromDocuments(filename: file) }
                            .buttonStyle(.bordered).controlSize(.small)
                    }
                }
                Divider()
            }
            Button { showDocumentPicker = true } label: {
                Label(vm.loadedTheme == nil ? "Choose .passthm…" : "Change .passthm…",
                      systemImage: "doc.badge.plus").frame(maxWidth: .infinity)
            }.buttonStyle(.bordered)

            if let theme = vm.loadedTheme {
                KeypadPreviewView(keys: theme.keysPreview).padding(.vertical, 6)
                Text("Files: \(theme.fileCount) · Keys: \(theme.keysPreview.count)")
                    .font(.caption).foregroundStyle(.secondary)
                Button { vm.flashPassthm() } label: {
                    Label("Flash Theme", systemImage: "bolt.fill").frame(maxWidth: .infinity).frame(height: 46)
                }.buttonStyle(.borderedProminent).disabled(!vm.canFlashPassthm)
                Button(role: .destructive) { vm.clearLoadedTheme() } label: {
                    Label("Unload Theme", systemImage: "trash").frame(maxWidth: .infinity)
                }.buttonStyle(.bordered)
            }
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .sheet(isPresented: $showDocumentPicker) {
            DocumentPickerView(allowedContentTypes: [UTType(filenameExtension: "passthm") ?? .archive, .zip, .archive]) {
                vm.loadPassthm(url: $0)
            }
        }
    }
}

struct ThemeCreatorSection: View {
    @EnvironmentObject var vm: AppViewModel
    @State private var selectedDigitForPicker: String? = nil
    @State private var showKeySourceDialog = false
    @State private var isKeyPhotosPickerPresented = false
    @State private var isKeyDocumentPickerPresented = false
    @State private var selectedKey: [PhotosPickerItem] = []
    @State private var showPosterSourceDialog = false
    @State private var isPosterPhotosPickerPresented = false
    @State private var isPosterDocumentPickerPresented = false
    @State private var selectedPoster: [PhotosPickerItem] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("Slice Mode", selection: $vm.sliceMode) {
                ForEach(SliceMode.allCases) { m in Text(m.rawValue).tag(m) }
            }.pickerStyle(.segmented)

            if vm.sliceMode == .posterSlice {
                Button { showPosterSourceDialog = true } label: {
                    Label(vm.posterImage == nil ? "Select Poster Image…" : "Change Poster…",
                          systemImage: "photo").frame(maxWidth: .infinity)
                }.buttonStyle(.bordered)
            } else {
                Text("Tap a key to assign image").font(.caption).foregroundStyle(.secondary)
                ForEach(KeypadLayout.allButtons) { btn in
                    HStack(spacing: 12) {
                        ZStack {
                            Circle().fill(.ultraThinMaterial).frame(width: 40, height: 40)
                            if let img = vm.customKeys[btn.digit] {
                                Image(uiImage: img).resizable().scaledToFill()
                                    .frame(width: 40, height: 40).clipShape(Circle())
                            } else { Text(btn.digit).font(.headline) }
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Key \(btn.digit)").font(.subheadline.weight(.medium))
                            if !btn.letters.isEmpty { Text(btn.letters).font(.caption2).foregroundStyle(.secondary) }
                        }
                        Spacer()
                        if vm.customKeys[btn.digit] != nil {
                            Button(role: .destructive) { vm.clearIndividualKey(digit: btn.digit) } label: {
                                Image(systemName: "xmark.circle.fill")
                            }.buttonStyle(.borderless)
                        } else { Image(systemName: "plus.circle.fill") }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { selectedDigitForPicker = btn.digit; showKeySourceDialog = true }
                }
            }

            KeypadPreviewView(keys: vm.effectiveKeys).padding(.vertical, 6)

            Button { vm.flashPassthm() } label: {
                Label("Flash Theme", systemImage: "bolt.fill").frame(maxWidth: .infinity).frame(height: 46)
            }.buttonStyle(.borderedProminent).disabled(!vm.canFlashPassthm)

            if !vm.effectiveKeys.isEmpty {
                Button { _ = vm.exportPassthm() } label: {
                    Label("Export .passthm", systemImage: "square.and.arrow.up").frame(maxWidth: .infinity)
                }.buttonStyle(.bordered)
                Button(role: .destructive) { vm.clearAllCreator() } label: {
                    Label("Clear All", systemImage: "trash").frame(maxWidth: .infinity)
                }.buttonStyle(.bordered)
            }
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .confirmationDialog("Poster Source", isPresented: $showPosterSourceDialog, titleVisibility: .visible) {
            Button("Photo Library") { isPosterPhotosPickerPresented = true }
            Button("Files…") { isPosterDocumentPickerPresented = true }
            Button("Cancel", role: .cancel) {}
        }
        .photosPicker(isPresented: $isPosterPhotosPickerPresented, selection: $selectedPoster, maxSelectionCount: 1, matching: .images)
        .onChange(of: selectedPoster) { _, items in
            guard let item = items.first else { return }
            Task {
                if let image = await item.loadUIImage(maxDimension: 2560) {
                    await MainActor.run { vm.setPosterImage(image) }
                }
                await MainActor.run { selectedPoster = [] }
            }
        }
        .sheet(isPresented: $isPosterDocumentPickerPresented) {
            DocumentPickerView(allowedContentTypes: [.image, .png, .jpeg, .heic]) { url in
                if let data = try? Data(contentsOf: url), let img = ImageEngine.safeImageFromData(data, maxDimension: 2560) {
                    vm.setPosterImage(img)
                }
            }
        }
        .confirmationDialog("Key Source", isPresented: $showKeySourceDialog, titleVisibility: .visible) {
            Button("Photo Library") { isKeyPhotosPickerPresented = true }
            Button("Files…") { isKeyDocumentPickerPresented = true }
            Button("Cancel", role: .cancel) { selectedDigitForPicker = nil }
        }
        .photosPicker(isPresented: $isKeyPhotosPickerPresented, selection: $selectedKey, maxSelectionCount: 1, matching: .images)
        .onChange(of: selectedKey) { _, items in
            guard let item = items.first, let digit = selectedDigitForPicker else { return }
            Task {
                if let image = await item.loadUIImage(maxDimension: 1024) {
                    await MainActor.run { vm.setIndividualKey(digit: digit, image: image) }
                }
                await MainActor.run { selectedKey = []; selectedDigitForPicker = nil }
            }
        }
        .sheet(isPresented: $isKeyDocumentPickerPresented) {
            DocumentPickerView(allowedContentTypes: [.image, .png, .jpeg, .heic]) { url in
                guard let digit = selectedDigitForPicker else { return }
                if let data = try? Data(contentsOf: url), let img = ImageEngine.safeImageFromData(data, maxDimension: 1024) {
                    vm.setIndividualKey(digit: digit, image: img)
                }
                selectedDigitForPicker = nil
            }
        }
    }
}

// MARK: - Keypad Preview

struct KeypadPreviewView: View {
    @EnvironmentObject var vm: AppViewModel
    let keys: [String: UIImage]

    var body: some View {
        let scale: CGFloat = 0.62
        let btnD: CGFloat = KeypadLayout.buttonDiameter * scale
        let colW: CGFloat = KeypadLayout.colWidth * scale
        let rowH: CGFloat = KeypadLayout.rowHeight * scale
        let gridW: CGFloat = KeypadLayout.gridWidth * scale
        let gridH: CGFloat = KeypadLayout.gridHeight * scale

        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous).fill(.ultraThinMaterial)
            ZStack {
                ForEach(KeypadLayout.allButtons) { btn in
                    let cx = CGFloat(btn.col) * colW + colW / 2
                    let cy = CGFloat(btn.row) * rowH + rowH / 2
                    ZStack {
                        Circle().fill(Color.white.opacity(0.10)).frame(width: btnD, height: btnD)
                        if let img = keys[btn.digit] {
                            Image(uiImage: img).resizable().aspectRatio(contentMode: .fill)
                                .frame(width: btnD, height: btnD).clipShape(Circle())
                        } else {
                            VStack(spacing: 0) {
                                Text(btn.digit).font(.system(size: 24 * scale, weight: .light)).foregroundStyle(.white)
                                if !btn.letters.isEmpty {
                                    Text(btn.letters).font(.system(size: 8 * scale, weight: .semibold))
                                        .foregroundStyle(.white.opacity(0.8))
                                }
                            }
                        }
                    }.position(x: cx, y: cy)
                }
            }.frame(width: gridW, height: gridH)
        }
        .frame(maxWidth: .infinity).frame(height: 280)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}