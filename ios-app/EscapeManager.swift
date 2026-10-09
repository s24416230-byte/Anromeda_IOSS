import Foundation
import UIKit

/// Swift-обёртка над Objective-C EscapeEngine / PlistWriter.
/// Все методы безопасны: возвращают Bool, не крашат приложение.
enum EscapeManager {

    // MARK: - Probe

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

    // MARK: - Preferences

    static func writeSpringBoardKey(_ key: String, value: Any) -> Bool {
        return EscapeEngine.writePref(key, value: value, appID: "com.apple.springboard")
    }

    static func readSpringBoardKeys() -> [String: Any]? {
        return EscapeEngine.readPrefApp("com.apple.springboard") as? [String: Any]
    }

    // MARK: - SpringBoard plist (прямая запись в файл)

    static let springBoardPath = "/var/mobile/Library/Preferences/com.apple.springboard.plist"

    static func readSpringBoardPlist() -> [String: Any]? {
        return PlistWriter.read(springBoardPath) as? [String: Any]
    }

    static func writeSpringBoardPlist(_ dict: [String: Any]) -> Bool {
        return PlistWriter.write(dict, toPath: springBoardPath)
    }

    static func setSpringBoardKey(_ key: String, value: Any) -> Bool {
        return PlistWriter.setKey(key, value: value, inFile: springBoardPath)
    }

    // MARK: - Respring

    static func respring() {
        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(),
            CFNotificationName("com.apple.springboard.restart" as CFString),
            nil, nil, true
        )
    }

    // MARK: - Logs

        static func log(_ message: String) {
        LogManager.shared()?.log("%@", message)
    }

        static func lines() -> [String] {
        return LogManager.shared()?.lines ?? []
    }

    static func clearLogs() {
        LogManager.shared()?.clear()
    }