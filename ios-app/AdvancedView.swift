import SwiftUI
import UIKit

struct AdvancedView: View {
    @State private var logs: [String] = []
    @State private var showLogs = true

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                headerCard
                springboardCard
                posterboardCard
                accessibilityCard
                carrierCard
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
            Text("SpringBoard, PosterBoard, Accessibility через EscapeEngine (AnyUser).")
                .font(.subheadline).foregroundStyle(.secondary)
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var springboardCard: some View {
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
            actionButton("Скрыть док", icon: "dock.rectangle") {
                let ok = EscapeManager.writeSpringBoardKey("SBDockView", value: false)
                EscapeManager.log("SBDockView: \(ok ? "OK" : "FAIL")")
                refreshLogs()
            }
            actionButton("Уменьшить иконки в доке", icon: "arrow.down.right.and.arrow.up.left") {
                let ok = EscapeManager.writeSpringBoardKey("SBDockIconScale", value: 0.85)
                EscapeManager.log("SBDockIconScale: \(ok ? "OK" : "FAIL")")
                refreshLogs()
            }
            actionButton("Отключить анимации", icon: "bolt.slash") {
                let ok = EscapeManager.writeSpringBoardKey("SBDisableAnimations", value: true)
                EscapeManager.log("SBDisableAnimations: \(ok ? "OK" : "FAIL")")
                refreshLogs()
            }
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var posterboardCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("PosterBoard (Обои)").font(.caption.bold().uppercaseSmallCaps()).foregroundStyle(.secondary)

            actionButton("Найти PosterBoard-контейнер", icon: "folder") {
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

    private var accessibilityCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Accessibility").font(.caption.bold().uppercaseSmallCaps()).foregroundStyle(.secondary)

            actionButton("Включить Reduce Transparency", icon: "circle.lefthalf.filled") {
                let ok = EscapeManager.writeAccessibilityKey("ReduceTransparencyEnabled", value: true)
                EscapeManager.log("ReduceTransparency: \(ok ? "OK" : "FAIL")")
                refreshLogs()
            }
            actionButton("Включить Increase Contrast", icon: "circle.righthalf.filled") {
                let ok = EscapeManager.writeAccessibilityKey("IncreaseContrastEnabled", value: true)
                EscapeManager.log("IncreaseContrast: \(ok ? "OK" : "FAIL")")
                refreshLogs()
            }
            actionButton("Включить Reduce Motion", icon: "figure.walk.motion") {
                let ok = EscapeManager.writeAccessibilityKey("ReduceMotionEnabled", value: true)
                EscapeManager.log("ReduceMotion: \(ok ? "OK" : "FAIL")")
                refreshLogs()
            }
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var carrierCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Carrier (альтернативные домены)").font(.caption.bold().uppercaseSmallCaps()).foregroundStyle(.secondary)

            actionButton("com.apple.carrier → CarrierName = Moon", icon: "antenna.radiowaves.left.and.right") {
                let ok = EscapeManager.writeCarrierKey("CarrierName", value: "Moon")
                EscapeManager.log("carrier.plist: \(ok ? "OK" : "FAIL")")
                refreshLogs()
            }
            actionButton("com.apple.operator → OperatorName = Moon", icon: "wifi") {
                let ok = EscapeManager.writeOperatorKey("OperatorName", value: "Moon")
                EscapeManager.log("operator.plist: \(ok ? "OK" : "FAIL")")
                refreshLogs()
            }
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var logsCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Логи").font(.caption.bold().uppercaseSmallCaps()).foregroundStyle(.secondary)
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