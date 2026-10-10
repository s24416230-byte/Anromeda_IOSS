import SwiftUI
import UIKit

struct AdvancedView: View {
    @State private var logs: [String] = []
    @State private var showLogs = true
    @State private var customKey: String = ""
    @State private var customValue: String = ""
    @State private var customAppID: String = "com.apple.springboard"

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                headerCard
                carrierLegacyCard
                carrierDualCard
                statusBarCard
                springBoardCard
                accessibilityCard
                posterboardCard
                dockIconsCard
                customKeyCard
                if showLogs { logsCard }
                Spacer(minLength: 40)
            }
            .padding(.vertical).padding(.horizontal)
        }
        .scrollContentBackground(.hidden)
        .navigationTitle("Advanced")
        .toolbarBackground(.hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { refreshLogs(); showLogs.toggle() } label: {
                    Image(systemName: showLogs ? "eye.slash" : "eye")
                }
            }
        }
        .onAppear { refreshLogs() }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: "wand.and.stars").font(.title2)
                Text("Advanced Tweaks").font(.title2.bold())
            }
            Text("Прямая запись в CFPreferences (AnyUser). Некоторые ключи iOS 27 игнорирует.")
                .font(.subheadline).foregroundStyle(.secondary)
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Legacy Carrier

    private var carrierLegacyCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Carrier — legacy ключи").font(.caption.bold().uppercaseSmallCaps()).foregroundStyle(.secondary)
            Text("Работали до iOS 14. Возможно, iOS 27 всё ещё читает для совместимости.")
                .font(.caption2).foregroundStyle(.secondary)

            actionButton("SBFakeCarrier = Moon", icon: "antenna.radiowaves.left.and.right") {
                let ok = EscapeManager.writeSpringBoardKey("SBFakeCarrier", value: "Moon")
                EscapeManager.log("SBFakeCarrier: \(ok ? "OK" : "FAIL")")
                refreshLogs()
            }
            actionButton("SBFakeCarrier2 = Moon", icon: "antenna.radiowaves.left.and.right") {
                let ok = EscapeManager.writeSpringBoardKey("SBFakeCarrier2", value: "Moon")
                EscapeManager.log("SBFakeCarrier2: \(ok ? "OK" : "FAIL")")
                refreshLogs()
            }
            actionButton("SBCarrierName = Moon", icon: "antenna.radiowaves.left.and.right") {
                let ok = EscapeManager.writeSpringBoardKey("SBCarrierName", value: "Moon")
                EscapeManager.log("SBCarrierName: \(ok ? "OK" : "FAIL")")
                refreshLogs()
            }
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Dual carrier

    private var carrierDualCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Carrier — все известные ключи").font(.caption.bold().uppercaseSmallCaps()).foregroundStyle(.secondary)

            actionButton("Записать все CarrierName-ключи", icon: "arrow.down.to.line") {
                let keys = ["CarrierName", "CarrierName2",
                            "SBFakeCarrier", "SBFakeCarrier2",
                            "SBCarrierName", "SBOverrideCarrierName",
                            "OperatorName", "FakeCarrierName"]
                for k in keys {
                    let ok = EscapeManager.writeSpringBoardKey(k, value: "Moon")
                    EscapeManager.log("\(k): \(ok ? "OK" : "FAIL")")
                }
                refreshLogs()
            }

            actionButton("Записать в com.apple.carrier", icon: "antenna.radiowaves.left.and.right") {
                let ok = EscapeManager.writeCarrierKey("CarrierName", value: "Moon")
                EscapeManager.log("carrier.plist: \(ok ? "OK" : "FAIL")")
                refreshLogs()
            }
            actionButton("Записать в com.apple.operator", icon: "wifi") {
                let ok = EscapeManager.writeOperatorKey("OperatorName", value: "Moon")
                EscapeManager.log("operator.plist: \(ok ? "OK" : "FAIL")")
                refreshLogs()
            }
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Status bar

    private var statusBarCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Status Bar").font(.caption.bold().uppercaseSmallCaps()).foregroundStyle(.secondary)

            actionButton("SBFakeTimeString = Andromeda", icon: "clock") {
                let ok = EscapeManager.writeSpringBoardKey("SBFakeTimeString", value: "Andromeda")
                EscapeManager.log("SBFakeTimeString: \(ok ? "OK" : "FAIL")")
                refreshLogs()
            }
            actionButton("SBFakeDateString = 2026", icon: "calendar") {
                let ok = EscapeManager.writeSpringBoardKey("SBFakeDateString", value: "2026")
                EscapeManager.log("SBFakeDateString: \(ok ? "OK" : "FAIL")")
                refreshLogs()
            }
            actionButton("SBFakeBatteryString = 100%", icon: "battery.100") {
                let ok = EscapeManager.writeSpringBoardKey("SBFakeBatteryString", value: "100%")
                EscapeManager.log("SBFakeBatteryString: \(ok ? "OK" : "FAIL")")
                refreshLogs()
            }
            actionButton("Hide status bar time (HideStatusBarTime)", icon: "eye.slash") {
                let ok = EscapeManager.writeSpringBoardKey("HideStatusBarTime", value: true)
                EscapeManager.log("HideStatusBarTime: \(ok ? "OK" : "FAIL")")
                refreshLogs()
            }
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - SpringBoard

    private var springBoardCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("SpringBoard").font(.caption.bold().uppercaseSmallCaps()).foregroundStyle(.secondary)

            actionButton("Скрыть иконку Калькулятора", icon: "eye.slash") {
                let ok = EscapeManager.writeSpringBoardKey("SBIconVisibilityDefaultVisible",
                                                           value: ["com.apple.calculator": false])
                EscapeManager.log("SBIconVisibility: \(ok ? "OK" : "FAIL")")
                refreshLogs()
            }
            actionButton("Показать иконку Калькулятора", icon: "eye") {
                let ok = EscapeManager.writeSpringBoardKey("SBIconVisibilityDefaultVisible",
                                                           value: ["com.apple.calculator": true])
                EscapeManager.log("SBIconVisibility: \(ok ? "OK" : "FAIL")")
                refreshLogs()
            }
            actionButton("SBShowNonDefaultSystemApps = true", icon: "app.badge") {
                let ok = EscapeManager.writeSpringBoardKey("SBShowNonDefaultSystemApps", value: true)
                EscapeManager.log("SBShowNonDefaultSystemApps: \(ok ? "OK" : "FAIL")")
                refreshLogs()
            }
            actionButton("SBDisableAnimations = true", icon: "bolt.slash") {
                let ok = EscapeManager.writeSpringBoardKey("SBDisableAnimations", value: true)
                EscapeManager.log("SBDisableAnimations: \(ok ? "OK" : "FAIL")")
                refreshLogs()
            }
            actionButton("SBShowBatteryPercentage = true", icon: "battery.100") {
                let ok = EscapeManager.writeSpringBoardKey("SBShowBatteryPercentage", value: true)
                EscapeManager.log("SBShowBatteryPercentage: \(ok ? "OK" : "FAIL")")
                refreshLogs()
            }
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Accessibility

    private var accessibilityCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Accessibility").font(.caption.bold().uppercaseSmallCaps()).foregroundStyle(.secondary)

            actionButton("Reduce Transparency = ON", icon: "circle.lefthalf.filled") {
                let ok = EscapeManager.writeAccessibilityKey("ReduceTransparencyEnabled", value: true)
                EscapeManager.log("ReduceTransparency: \(ok ? "OK" : "FAIL")")
                refreshLogs()
            }
            actionButton("Reduce Transparency = OFF", icon: "circle.righthalf.filled") {
                let ok = EscapeManager.writeAccessibilityKey("ReduceTransparencyEnabled", value: false)
                EscapeManager.log("ReduceTransparency OFF: \(ok ? "OK" : "FAIL")")
                refreshLogs()
            }
            actionButton("Increase Contrast = ON", icon: "circle.righthalf.filled") {
                let ok = EscapeManager.writeAccessibilityKey("IncreaseContrastEnabled", value: true)
                EscapeManager.log("IncreaseContrast: \(ok ? "OK" : "FAIL")")
                refreshLogs()
            }
            actionButton("Reduce Motion = ON", icon: "figure.walk.motion") {
                let ok = EscapeManager.writeAccessibilityKey("ReduceMotionEnabled", value: true)
                EscapeManager.log("ReduceMotion: \(ok ? "OK" : "FAIL")")
                refreshLogs()
            }
            actionButton("Bold Text = ON", icon: "bold") {
                let ok = EscapeManager.writeAccessibilityKey("BoldTextEnabled", value: true)
                EscapeManager.log("BoldText: \(ok ? "OK" : "FAIL")")
                refreshLogs()
            }
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - PosterBoard

    private var posterboardCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("PosterBoard (Обои)").font(.caption.bold().uppercaseSmallCaps()).foregroundStyle(.secondary)

            actionButton("Найти контейнер", icon: "folder") {
                if let c = EscapeManager.posterBoardContainer() {
                    EscapeManager.log("Container: \(c)")
                } else {
                    EscapeManager.log("Container not found")
                }
                refreshLogs()
            }
            actionButton("Список .tendies", icon: "list.bullet") {
                let list = EscapeManager.installedTendies()
                EscapeManager.log("Tendies: \(list.isEmpty ? "(empty)" : list.joined(separator: ", "))")
                refreshLogs()
            }
            actionButton("Сбросить кэш обоев", icon: "arrow.clockwise") {
                EscapeManager.invalidatePosterBoard()
                EscapeManager.log("PosterBoard cache invalidated")
                refreshLogs()
            }
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Dock & Icons

    private var dockIconsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Dock & Icons").font(.caption.bold().uppercaseSmallCaps()).foregroundStyle(.secondary)

            actionButton("Скрыть док (SBDockView)", icon: "dock.rectangle") {
                let ok = EscapeManager.writeSpringBoardKey("SBDockView", value: false)
                EscapeManager.log("SBDockView: \(ok ? "OK" : "FAIL")")
                refreshLogs()
            }
            actionButton("Показать док", icon: "dock.rectangle") {
                let ok = EscapeManager.writeSpringBoardKey("SBDockView", value: true)
                EscapeManager.log("SBDockView: \(ok ? "OK" : "FAIL")")
                refreshLogs()
            }
            actionButton("Иконки дока меньше (0.85)", icon: "arrow.down.right.and.arrow.up.left") {
                let ok = EscapeManager.writeSpringBoardKey("SBDockIconScale", value: 0.85)
                EscapeManager.log("SBDockIconScale: \(ok ? "OK" : "FAIL")")
                refreshLogs()
            }
            actionButton("Скрыть home bar (SBFHomeBar)", icon: "rectangle.bottomthird.inset.filled") {
                let ok = EscapeManager.writeSpringBoardKey("SBFHomeBar", value: false)
                EscapeManager.log("SBFHomeBar: \(ok ? "OK" : "FAIL")")
                refreshLogs()
            }
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Custom key

    private var customKeyCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Свой ключ").font(.caption.bold().uppercaseSmallCaps()).foregroundStyle(.secondary)

            TextField("appID (com.apple.springboard)", text: $customAppID)
                .textFieldStyle(.plain)
                .padding(.horizontal, 10).padding(.vertical, 8)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))

            TextField("key", text: $customKey)
                .textFieldStyle(.plain)
                .padding(.horizontal, 10).padding(.vertical, 8)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))

            TextField("value", text: $customValue)
                .textFieldStyle(.plain)
                .padding(.horizontal, 10).padding(.vertical, 8)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))

            Button {
                let ok = EscapeManager.writePref(customKey, value: customValue, appID: customAppID)
                EscapeManager.log("custom \(customAppID)/\(customKey): \(ok ? "OK" : "FAIL")")
                refreshLogs()
            } label: {
                Label("Записать", systemImage: "arrow.down.to.line")
                    .frame(maxWidth: .infinity).frame(height: 44)
            }
            .buttonStyle(.borderedProminent)
            .disabled(customKey.isEmpty || customValue.isEmpty)
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    // MARK: - Logs

    private var logsCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Логи").font(.caption.bold().uppercaseSmallCaps()).foregroundStyle(.secondary)
                Spacer()
                Button {
                    EscapeManager.clearLogs()
                    refreshLogs()
                } label: {
                    Image(systemName: "trash").font(.caption)
                }.buttonStyle(.plain)
            }
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 2) {
                    ForEach(Array(logs.enumerated()), id: \.offset) { _, line in
                        Text(line)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(8)
            }
            .frame(maxHeight: 240)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func actionButton(_ title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon).frame(width: 22)
                Text(title).font(.subheadline.weight(.medium))
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
    }

    private func refreshLogs() {
        logs = EscapeManager.lines()
    }
}