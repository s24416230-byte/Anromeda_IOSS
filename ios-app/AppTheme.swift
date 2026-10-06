import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    case emerald = "Emerald"
    case bloodMoon = "Blood Moon"
    case sky = "Sky"
    case pinky = "Pinky"
    case violet = "Violet"

    var id: String { rawValue }

    /// Dopamine-style two-stop gradient for the whole app background.
    var backgroundColors: [Color] {
        switch self {
        case .emerald:
            return [Color(red: 0.02, green: 0.12, blue: 0.08),
                    Color(red: 0.00, green: 0.04, blue: 0.03)]
        case .bloodMoon:
            return [Color(red: 0.20, green: 0.03, blue: 0.05),
                    Color(red: 0.06, green: 0.01, blue: 0.02)]
        case .sky:
            return [Color(red: 0.03, green: 0.10, blue: 0.22),
                    Color(red: 0.01, green: 0.03, blue: 0.10)]
        case .pinky:
            return [Color(red: 0.20, green: 0.03, blue: 0.15),
                    Color(red: 0.07, green: 0.01, blue: 0.06)]
        case .violet:
            return [Color(red: 0.14, green: 0.03, blue: 0.24),
                    Color(red: 0.05, green: 0.01, blue: 0.12)]
        }
    }

    var accent: Color {
        switch self {
        case .emerald:   return Color(red: 0.30, green: 0.92, blue: 0.55)
        case .bloodMoon: return Color(red: 1.00, green: 0.26, blue: 0.28)
        case .sky:       return Color(red: 0.36, green: 0.68, blue: 1.00)
        case .pinky:     return Color(red: 1.00, green: 0.42, blue: 0.72)
        case .violet:    return Color(red: 0.72, green: 0.46, blue: 1.00)
        }
    }

    var accentSoft: Color { accent.opacity(0.18) }

    var backgroundGradient: LinearGradient {
        LinearGradient(colors: backgroundColors, startPoint: .top, endPoint: .bottom)
    }
}