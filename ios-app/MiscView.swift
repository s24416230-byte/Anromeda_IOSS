//
//  MiscView.swift
//  Andromeda
//
//  Misc tab: airlift sandbox paths, system settings shortcuts,
//  hidden features info, and JIT enabler.
//

import SwiftUI
import UIKit

struct MiscView: View {
    @EnvironmentObject var vm: AppViewModel
    @AppStorage("andromeda.jit.enabled") private var jitEnabled = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    sandboxPathsCard
                    systemSettingsCard
                    jitCard
                    hiddenFeaturesCard
                    Spacer(minLength: 40)
                }
                .padding(.vertical).padding(.horizontal)
            }
            .scrollContentBackground(.hidden).background(Color.clear)
            .navigationTitle("Misc")
        }
    }

    // MARK: - Airlift sandbox paths

    private var sandboxPathsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "folder.fill").font(.title3)
                Text("Airlift Sandbox Access").font(.headline)
            }
            Text("Paths writable through the Airlift exploit. Tap to copy.")
                .font(.caption).foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 6) {
                pathRow("/var/mobile/Library/Passes/Cards")
                pathRow("/var/mobile/Library/Caches/TelephonyUI-10")
                pathRow("/var/mobile/Library/Caches/TelephonyUI-9")
                pathRow("/var/mobile/Library/Caches/TelephonyUI-8")
                pathRow("/var/mobile/Library/SpringBoard")
                pathRow("/var/mobile/Library/Preferences")
                pathRow("/var/mobile/Containers/Shared/AppGroup")
            }
        }
        .padding(14).dopeCard(cornerRadius: 16)
    }

    private func pathRow(_ path: String) -> some View {
        Button {
            UIPasteboard.general.string = path
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "doc.text").font(.caption2).foregroundStyle(.secondary)
                Text(path)
                    .font(.system(size: 11, design: .monospaced))
                    .lineLimit(1).truncationMode(.middle)
                Spacer()
                Image(systemName: "doc.on.doc").font(.caption2).foregroundStyle(.secondary)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - System settings shortcuts

    private var systemSettingsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "gearshape.2.fill").font(.title3)
                Text("System Settings").font(.headline)
            }
            Text("Open system panels directly. Some require iOS 26+ or manual selection.")
                .font(.caption).foregroundStyle(.secondary)

            VStack(spacing: 8) {
                settingsRow("Color Filters", icon: "paintpalette.fill",
                            url: "App-Prefs:root=ACCESSIBILITY&path=DISPLAY_AND_TEXT")
                settingsRow("Reduce Transparency", icon: "rectangle.on.rectangle.slash.fill",
                            url: "App-Prefs:root=ACCESSIBILITY&path=DISPLAY_AND_TEXT")
                settingsRow("Liquid Glass (if available)", icon: "drop.fill",
                            url: "App-Prefs:root=DISPLAY")
                settingsRow("Wallpaper", icon: "photo.fill",
                            url: "App-Prefs:root=Wallpaper")
                settingsRow("Developer Mode", icon: "hammer.fill",
                            url: "App-Prefs:root=Privacy&path=DEVELOPER_MODE")
            }
        }
        .padding(14).dopeCard(cornerRadius: 16)
    }

    private func settingsRow(_ title: String, icon: String, url: String) -> some View {
        Button {
            if let u = URL(string: url) {
                UIApplication.shared.open(u, options: [:], completionHandler: nil)
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: icon).font(.subheadline).frame(width: 22)
                Text(title).font(.subheadline)
                Spacer()
                Image(systemName: "arrow.up.forward.app").font(.caption).foregroundStyle(.secondary)
            }
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
    }

    // MARK: - JIT

    private var jitCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "bolt.fill").font(.title3)
                Text("JIT Enabler").font(.headline)
                Spacer()
                Toggle("", isOn: $jitEnabled).labelsHidden()
            }
            Text("JIT (Just-In-Time) requires TrollStore or a sideloader with JIT support. This toggle sets a preference flag for compatible loaders.")
                .font(.caption).foregroundStyle(.secondary)
            Text(jitEnabled ? "Status: enabled" : "Status: disabled")
                .font(.caption2.bold()).foregroundStyle(jitEnabled ? .green : .secondary)
        }
        .padding(14).dopeCard(cornerRadius: 16)
    }

    // MARK: - Hidden features info

    private var hiddenFeaturesCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "eye.slash.fill").font(.title3)
                Text("Hidden Features").font(.headline)
            }
            Text("Some iOS tweaks require MobileGestalt (not accessible via Airlift on iOS 26+):")
                .font(.caption).foregroundStyle(.secondary)
            VStack(alignment: .leading, spacing: 6) {
                Text("• Carrier name — needs MobileGestalt")
                Text("• Status bar time/date text — needs MobileGestalt")
                Text("• System font — needs MobileGestalt")
                Text("• Liquid Glass toggle — set by user in Settings → Accessibility")
            }
            .font(.caption2).foregroundStyle(.secondary)
        }
        .padding(14).dopeCard(cornerRadius: 16)
    }
}