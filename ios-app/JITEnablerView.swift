import SwiftUI

struct JITEnablerView: View {
    @AppStorage("andromeda.jit.enabled") private var jitEnabled = false
    @State private var statusMessage = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    headerCard
                    statusCard
                    actionsCard
                    infoCard
                    Spacer(minLength: 40)
                }
                .padding(.vertical).padding(.horizontal)
            }
            .scrollContentBackground(.hidden).background(Color.clear)
            .navigationTitle("JIT Enabler")
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: "bolt.fill").font(.title2)
                Text("JIT Enabler").font(.title2.bold())
            }
            Text("Enable Just-In-Time compilation for sideloaded apps. Requires TrollStore or a compatible sideloader with JIT support.")
                .font(.subheadline).foregroundStyle(.secondary)
        }
        .padding(14).dopeCard(cornerRadius: 16)
    }

    private var statusCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: jitEnabled ? "checkmark.seal.fill" : "xmark.seal.fill")
                    .foregroundStyle(jitEnabled ? .green : .secondary)
                Text(jitEnabled ? "JIT enabled" : "JIT disabled").font(.subheadline.bold())
            }
            if !statusMessage.isEmpty {
                Text(statusMessage).font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(14).dopeCard(cornerRadius: 16)
    }

    private var actionsCard: some View {
        VStack(spacing: 12) {
            Button {
                jitEnabled.toggle()
                statusMessage = jitEnabled
                    ? "Enabled flag set. Restart target app to apply."
                    : "Disabled."
            } label: {
                Label(jitEnabled ? "Disable JIT" : "Enable JIT",
                      systemImage: jitEnabled ? "bolt.slash.fill" : "bolt.fill")
                    .frame(maxWidth: .infinity).frame(height: 48).font(.headline)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(14).dopeCard(cornerRadius: 16)
    }

    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("How to use").font(.subheadline.bold())
            Text("1. Install the target app via TrollStore (JIT always works).")
            Text("2. Or use Sideloadly with 'Enable JIT' on the target app.")
            Text("3. Return here to verify status.")
            Text("Note: iOS 26+ restricts JIT for non-TrollStore apps. This screen sets a flag for compatible loaders.")
        }
        .font(.footnote).foregroundStyle(.secondary)
        .padding(14).dopeCard(cornerRadius: 16)
    }
}