import SwiftUI

struct SpringBoardView: View {
    @State private var carrierName: String = "Moon"
    @State private var logs: [String] = []
    @State private var showLogs = false

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                headerCard
                carrierCard
                quickActionsCard
                if showLogs { logsCard }
                Spacer(minLength: 40)
            }
            .padding(.vertical).padding(.horizontal)
        }
        .scrollContentBackground(.hidden)
        .navigationTitle("SpringBoard")
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
                Image(systemName: "gearshape.2.fill").font(.title2)
                Text("SpringBoard").font(.title2.bold())
            }
            Text("Прямая запись в com.apple.springboard.plist через EscapeEngine. MobileGestalt пока недоступен.")
                .font(.subheadline).foregroundStyle(.secondary)

            let p = EscapeManager.probe()
            HStack(spacing: 6) {
                Circle()
                    .fill(p.working ? Color.green : Color.orange)
                    .frame(width: 8, height: 8)
                Text(p.working ? "EscapeEngine OK" : "EscapeEngine не активен")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var carrierCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Carrier Name").font(.caption.bold().uppercaseSmallCaps()).foregroundStyle(.secondary)

            HStack(spacing: 8) {
                TextField("Moon", text: $carrierName)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 10).padding(.vertical, 8)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                Button("Применить") {
                    applyCarrier()
                }
                .buttonStyle(.borderedProminent)
            }

            Text("Запишет CarrierName в SpringBoard plist. После применения — respring.")
                .font(.caption2).foregroundStyle(.secondary)
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var quickActionsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Быстрые действия").font(.caption.bold().uppercaseSmallCaps()).foregroundStyle(.secondary)

            actionButton("Respring", icon: "bolt.fill") {
                EscapeManager.respring()
                EscapeManager.log("Respring triggered")
                refreshLogs()
            }
            actionButton("Прочитать SpringBoard keys", icon: "doc.text") {
                if let keys = EscapeManager.readSpringBoardKeys() {
                    EscapeManager.log("SB keys: \(keys.count)")
                    for (k, v) in keys.prefix(20) {
                        EscapeManager.log("  \(k) = \(v)")
                    }
                } else {
                    EscapeManager.log("SB read failed")
                }
                refreshLogs()
            }
            actionButton("Очистить логи", icon: "trash") {
                EscapeManager.clearLogs()
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
            .frame(maxHeight: 220)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func actionButton(_ title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon).frame(width: 20)
                Text(title).font(.subheadline.weight(.medium))
                Spacer()
                Image(systemName: "chevron.right").font(.caption).foregroundStyle(.secondary)
            }
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
    }

    private func applyCarrier() {
        _ = EscapeEngine.escapeToPath(EscapeManager.springBoardPath, write: true)
        var dict = EscapeManager.readSpringBoardPlist() ?? [:]
        dict["CarrierName"] = carrierName
        dict["CarrierName2"] = carrierName
        let ok = EscapeManager.writeSpringBoardPlist(dict)
        EscapeManager.log("carrier \(carrierName): \(ok ? "OK" : "FAIL")")
        if ok {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                EscapeManager.respring()
            }
        }
        refreshLogs()
    }

    private func refreshLogs() {
        logs = EscapeManager.lines()
    }
}