import Foundation
import UIKit

enum EscapeManager {

    struct ProbeResult {
        let extensionIssue: Bool
        let extensionConsume: Bool
        let tokenIssued: Bool
        let tokenConsumed: Bool
        let systemGroupReachable: Bool
        let preferencesReachable: Bool
        var working: Bool { extensionIssue && tokenIssued && tokenConsumed }
    }

    static func probe() -> ProbeResult {
        guard let dict = EscapeEngine.probeSurface() as? [String: Any] else {
            return ProbeResult(extensionIssue: false, extensionConsume: false,
                               tokenIssued: false, tokenConsumed: false,
                               systemGroupReachable: false, preferencesReachable: false)
        }
        return ProbeResult(
            extensionIssue:    (dict["extension_issue"] as? Bool) ?? false,
            extensionConsume:  (dict["extension_consume"] as? Bool) ?? false,
            tokenIssued:       (dict["token_issued"] as? Bool) ?? false,
            tokenConsumed:     (dict["token_consumed"] as? Bool) ?? false,
            systemGroupReachable: ((dict["stat_/var/containers/Shared/SystemGroup"] as? Bool) ?? false),
            preferencesReachable: ((dict["stat_/var/mobile/Library/Preferences"] as? Bool) ?? false)
        )
    }

    @discardableResult
    static func escapeToPath(_ path: String, write: Bool) -> Bool {
        let result = EscapeEngine.escapeToPath(path, write: write)
        return result == .success
    }

    // MARK: - SpringBoard

    static func writeSpringBoardKey(_ key: String, value: Any) -> Bool {
        return EscapeEngine.writeAnyUserPref(key, value: value, appID: "com.apple.springboard")
    }

    static func readSpringBoardKeys() -> [String: Any]? {
        if let anyUser = EscapeEngine.readAnyUserPrefApp("com.apple.springboard") as? [String: Any],
           !anyUser.isEmpty { return anyUser }
        return EscapeEngine.readPrefApp("com.apple.springboard") as? [String: Any]
    }

    static func deleteSpringBoardKey(_ key: String) -> Bool {
        return EscapeEngine.deletePref(key, appID: "com.apple.springboard")
    }

    // MARK: - Carrier

    static func writeCarrierKey(_ key: String, value: Any) -> Bool {
        return EscapeEngine.writeAnyUserPref(key, value: value, appID: "com.apple.carrier")
    }

    static func writeOperatorKey(_ key: String, value: Any) -> Bool {
        return EscapeEngine.writeAnyUserPref(key, value: value, appID: "com.apple.operator")
    }

    // MARK: - Accessibility

    static func writeAccessibilityKey(_ key: String, value: Any) -> Bool {
        return EscapeEngine.writeAnyUserPref(key, value: value, appID: "com.apple.Accessibility")
    }

    // MARK: - Универсальный преф для любого appID

    static func writePref(_ key: String, value: Any, appID: String) -> Bool {
        return EscapeEngine.writeAnyUserPref(key, value: value, appID: appID)
    }

    // MARK: - SpringBoard plist (прямая запись)

    static let springBoardPath = "/var/mobile/Library/Preferences/com.apple.springboard.plist"

    static func readSpringBoardPlist() -> [String: Any]? {
        return PlistWriter.read(springBoardPath) as? [String: Any]
    }

    static func writeSpringBoardPlist(_ dict: [String: Any]) -> Bool {
        return PlistWriter.write(dict, toPath: springBoardPath)
    }

    // MARK: - PosterBoard

    static func posterBoardContainer() -> String? {
        return EscapeEngine.posterBoardContainer()
    }

    static func installedTendies() -> [String] {
        guard let dir = EscapeEngine.collectionsDir() else { return [] }
        let url = URL(fileURLWithPath: dir)
        return (try? FileManager.default.contentsOfDirectory(atPath: url.path)) ?? []
    }

    static func invalidatePosterBoard() {
        guard let dir = EscapeEngine.collectionsDir() else { return }
        try? FileManager.default.removeItem(atPath: dir + "/.cache")
    }

    // MARK: - Respring (не работает на iOS 27)

    static func respring() {
        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(),
            CFNotificationName("com.apple.springboard.restart" as CFString),
            nil, nil, true
        )
    }

    // MARK: - Logs

    static func log(_ message: String) {
        LogManager.shared()?.logString(message)
    }

    static func lines() -> [String] {
        return LogManager.shared()?.lines ?? []
    }

    static func clearLogs() {
        LogManager.shared()?.clear()
    }
}