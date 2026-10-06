import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var vm: AppViewModel
    @AppStorage("andromeda.theme") private var themeRaw = AppTheme.emerald.rawValue
    @AppStorage("andromeda.dopamineUI") private var dopamineUI = true

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    themeCard
                    uiCard
                    exploitCard
                    aboutCard
                    Spacer(minLength: 40)
                }
                .padding(.vertical).padding(.horizontal)
            }
            .scrollContentBackground(.hidden).background(Color.clear)
            .navigationTitle("Settings")
        }
    }

    private var themeCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Theme").font(.caption.bold().uppercaseSmallCaps()).foregroundStyle(.secondary)
            ThemePickerBar()
        }
        .padding(14).dopeCard(cornerRadius: 16)
    }

    private var uiCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Interface").font(.caption.bold().uppercaseSmallCaps()).foregroundStyle(.secondary)
            Toggle(isOn: $dopamineUI) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Dopamine UI").font(.subheadline.weight(.medium))
                    Text("Gradient background, blur cards, no outlines")
                        .font(.caption2).foregroundStyle(.secondary)
                }
            }
        }
        .padding(14).dopeCard(cornerRadius: 16)
    }

    private var exploitCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Exploit").font(.caption.bold().uppercaseSmallCaps()).foregroundStyle(.secondary)
            HStack {
                Image(systemName: vm.vpnUp ? "checkmark.shield.fill" : "exclamationmark.triangle.fill")
                    .foregroundStyle(vm.vpnUp ? .green : .orange)
                Text("VPN: \(vm.vpnUp ? "Active" : "Off")").font(.subheadline)
                Spacer()
            }
            HStack {
                Image(systemName: vm.hasPairingFile ? "checkmark.seal.fill" : "xmark.seal.fill")
                    .foregroundStyle(vm.hasPairingFile ? .green : .orange)
                Text("Pairing: \(vm.hasPairingFile ? "Ready" : "Not Paired")").font(.subheadline)
                Spacer()
            }
            Button {
                RespringHelper.triggerNeoSpring()
            } label: {
                Label("Respring (NeoSpring)", systemImage: "bolt.fill")
                    .frame(maxWidth: .infinity).frame(height: 44)
            }.buttonStyle(.bordered)
        }
        .padding(14).dopeCard(cornerRadius: 16)
    }

    private var aboutCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("About").font(.caption.bold().uppercaseSmallCaps()).foregroundStyle(.secondary)
            HStack {
                Text("Version").font(.subheadline)
                Spacer()
                Text("1.3.1").font(.subheadline.monospaced()).foregroundStyle(.secondary)
            }
            HStack {
                Text("Developer").font(.subheadline)
                Spacer()
                Text("@moondevvv").font(.subheadline.bold())
            }
            HStack {
                Text("Exploit").font(.subheadline)
                Spacer()
                Text("airlift").font(.subheadline.monospaced()).foregroundStyle(.secondary)
            }
        }
        .padding(14).dopeCard(cornerRadius: 16)
    }
}