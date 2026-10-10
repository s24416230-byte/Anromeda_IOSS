import SwiftUI
import UIKit

struct MobileGestaltView: View {
    @State private var logs: [String] = []
    @State private var gestaltKeys: [String: Any] = [:]
    @State private var showKeys = false
    @State private var customKey = "ArtworkDeviceProductDescription"
    @State private var customValue = "Moon Phone"

    private let gestaltPath = "/var/containers/Shared/SystemGroup/systemgroup.com.apple.mobilegestaltcache/Library/Caches/com.apple.MobileGestalt.plist"
    private let gestaltDir  = "/var/containers/Shared/SystemGroup/systemgroup.com.apple.mobilegestaltcache/Library/Caches"

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                warningCard
                headerCard
                actionsCard
                deviceCard
                liquidGlassCard
                regionCard
                faceTimeCard
                customCard
                if showKeys { keysCard }
                logsCard
                Spacer(minLength: 40)
            }
            .padding(.vertical).padding(.horizontal)
        }
        .scrollContentBackground(.hidden)
        .navigationTitle("MobileGestalt")
        .toolbarBackground(.hidden, for: .navigationBar)
        .onAppear { refreshLogs() }
    }

    private var warningCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.orange)
                Text("Осторожно").font(.headline)
            }
            Text("Экспериментальная вкладка. Изменение MobileGestalt может привести к bootloop.")
                .font(.caption).foregroundStyle(.secondary)
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: "cpu.fill").font(.title2)
                Text("MobileGestalt").font(.title2.bold())
            }
            Text(gestaltPath)
                .font(.system(size: 9, design: .monospaced))
                .foregroundStyle(.secondary)
                .lineLimit(3)
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var actionsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Действия").font(.caption.bold().uppercaseSmallCaps()).foregroundStyle(.secondary)
            actionButton("Проверить доступ к файлу", icon: "lock.open") { checkAccess() }
            actionButton("Прочитать MobileGestalt.plist", icon: "doc.text") { readGestalt() }
            actionButton("Прочитать CacheExtra", icon: "list.bullet") { readCacheExtra() }
            actionButton("Открыть папку в Filza", icon: "arrow.up.forward.app") { openInFilza() }
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var deviceCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Модель устройства").font(.caption.bold().uppercaseSmallCaps()).foregroundStyle(.secondary)
            actionButton("Model → iPhone 17 Pro Max", icon: "iphone") {
                writeGestaltKey("ArtworkDeviceProductDescription", value: "iPhone 17 Pro Max")
            }
            actionButton("Model → Moon Phone", icon: "iphone") {
                writeGestaltKey("ArtworkDeviceProductDescription", value: "Moon Phone")
            }
            actionButton("Build → 1.0.0", icon: "hammer") {
                writeGestaltKey("BuildVersion", value: "1.0.0")
            }
            actionButton("Hardware → iPhone18,1", icon: "cpu") {
                writeGestaltKey("hw.model", value: "iPhone18,1")
            }
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var liquidGlassCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Liquid Glass & UI").font(.caption.bold().uppercaseSmallCaps()).foregroundStyle(.secondary)
            actionButton("Отключить Liquid Glass (green-tea = false)", icon: "drop.slash") {
                writeGestaltKey("green-tea", value: false)
            }
            actionButton("Включить Liquid Glass (green-tea = true)", icon: "drop.fill") {
                writeGestaltKey("green-tea", value: true)
            }
            actionButton("not-green-tea = true", icon: "leaf") {
                writeGestaltKey("not-green-tea", value: true)
            }
            actionButton("Упрощённые анимации", icon: "figure.walk.motion") {
                writeGestaltKey("SBReduceMotion", value: true)
            }
            actionButton("Отключить прозрачность", icon: "circle.lefthalf.filled") {
                writeGestaltKey("ReduceTransparency", value: true)
            }
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var regionCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Регион").font(.caption.bold().uppercaseSmallCaps()).foregroundStyle(.secondary)
            actionButton("Region → US (LL/A)", icon: "globe.americas.fill") {
                writeGestaltKey("h63QSdBCiT/z0WU6rdQv6Q", value: "LL/A")
            }
            actionButton("Region → China (CH/A)", icon: "globe.asia.australia.fill") {
                writeGestaltKey("h63QSdBCiT/z0WU6rdQv6Q", value: "CH/A")
            }
            actionButton("Region → Germany (ZD/A)", icon: "globe.europe.africa.fill") {
                writeGestaltKey("h63QSdBCiT/z0WU6rdQv6Q", value: "ZD/A")
            }
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var faceTimeCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("FaceTime / Звонки").font(.caption.bold().uppercaseSmallCaps()).foregroundStyle(.secondary)
            actionButton("Включить FaceTime Audio", icon: "phone.fill") {
                writeGestaltKey("not-green-tea", value: true)
            }
            actionButton("Отключить региональную блокировку", icon: "lock.open.fill") {
                writeGestaltKey("RegionalBehaviorAll", value: true)
            }
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var customCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Свой ключ").font(.caption.bold().uppercaseSmallCaps()).foregroundStyle(.secondary)
            TextField("key", text: $customKey)
                .textFieldStyle(.plain)
                .font(.system(size: 12, design: .monospaced))
                .padding(.horizontal, 10).padding(.vertical, 8)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
            TextField("value", text: $customValue)
                .textFieldStyle(.plain)
                .font(.system(size: 12, design: .monospaced))
                .padding(.horizontal, 10).padding(.vertical, 8)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
            Button {
                writeGestaltKey(customKey, value: customValue)
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

    private var keysCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Ключи (\(gestaltKeys.count))").font(.caption.bold().uppercaseSmallCaps()).foregroundStyle(.secondary)
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 2) {
                    ForEach(Array(gestaltKeys.keys.sorted().enumerated()), id: \.offset) { _, key in
                        Text("\(key) = \(String(describing: gestaltKeys[key] ?? ""))")
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(8)
            }
            .frame(maxHeight: 300)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var logsCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Логи").font(.caption.bold().uppercaseSmallCaps()).foregroundStyle(.secondary)
                Spacer()
                Button { EscapeManager.clearLogs(); refreshLogs() } label: {
                    Image(systemName: "trash").font(.caption)
                }.buttonStyle(.plain)
            }
            ScrollView {
                ForEach(Array(logs.enumerated()), id: \.offset) { _, line in
                    Text(line)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(maxHeight: 220)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func checkAccess() {
        let escaped = EscapeManager.escapeToPath(gestaltPath, write: false)
        EscapeManager.log("escapeToPath(gestalt): \(escaped ? "OK" : "FAIL")")
        let exists = FileManager.default.fileExists(atPath: gestaltPath)
        EscapeManager.log("fileExists: \(exists)")
        refreshLogs()
    }

    private func readGestalt() {
        let escaped = EscapeManager.escapeToPath(gestaltPath, write: false)
        EscapeManager.log("escape: \(escaped ? "OK" : "FAIL")")
        if let dict = NSDictionary(contentsOfFile: gestaltPath) as? [String: Any] {
            gestaltKeys = dict
            showKeys = true
            EscapeManager.log("read OK: \(dict.count) keys")
        } else {
            EscapeManager.log("read FAIL: file not accessible")
        }
        refreshLogs()
    }

    private func readCacheExtra() {
        if let dict = NSDictionary(contentsOfFile: gestaltPath) as? [String: Any],
           let cache = dict["CacheExtra"] as? [String: Any] {
            gestaltKeys = cache
            showKeys = true
            EscapeManager.log("CacheExtra: \(cache.count) keys")
        } else {
            EscapeManager.log("CacheExtra not found")
        }
        refreshLogs()
    }

    private func writeGestaltKey(_ key: String, value: Any) {
        EscapeManager.log("── write \(key) = \(value)")
        let cfOk = EscapeManager.writePref(key, value: value, appID: "com.apple.MobileGestalt")
        EscapeManager.log("  CFPreferences: \(cfOk ? "OK" : "FAIL")")

        if var dict = NSDictionary(contentsOfFile: gestaltPath) as? [String: Any] {
            var cache = dict["CacheExtra"] as? [String: Any] ?? [:]
            cache[key] = value
            dict["CacheExtra"] = cache
            _ = EscapeManager.escapeToPath(gestaltPath, write: true)
            let plOk = PlistWriter.write(dict, toPath: gestaltPath)
            EscapeManager.log("  PlistWriter: \(plOk ? "OK" : "FAIL")")
        } else {
            EscapeManager.log("  PlistWriter: file not readable")
        }
        refreshLogs()
    }

    private func openInFilza() {
        let url = URL(string: "filza://\(gestaltDir)")!
        UIApplication.shared.open(url)
        EscapeManager.log("opened in Filza: \(gestaltDir)")
        refreshLogs()
    }

    private func actionButton(_ title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon).frame(width: 22)
                Text(title).font(.subheadline.weight(.medium)).multilineTextAlignment(.leading)
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