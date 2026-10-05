import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    case emerald = "Emerald"
    case bloodMoon = "Blood Moon"
    case sky = "Sky"
    case pinky = "Pinky"
    case violet = "Violet"

    var id: String { rawValue }

    var backgroundColors: [Color] {
        switch self {
        case .emerald:
            return [Color(red: 0.04, green: 0.14, blue: 0.09),
                    Color(red: 0.02, green: 0.07, blue: 0.05)]
        case .bloodMoon:
            return [Color(red: 0.18, green: 0.04, blue: 0.06),
                    Color(red: 0.08, green: 0.02, blue: 0.03)]
        case .sky:
            return [Color(red: 0.04, green: 0.10, blue: 0.18),
                    Color(red: 0.02, green: 0.05, blue: 0.10)]
        case .pinky:
            return [Color(red: 0.16, green: 0.04, blue: 0.13),
                    Color(red: 0.08, green: 0.02, blue: 0.07)]
        case .violet:
            return [Color(red: 0.11, green: 0.04, blue: 0.18),
                    Color(red: 0.05, green: 0.02, blue: 0.10)]
        }
    }

    var accent: Color {
        switch self {
        case .emerald:   return Color(red: 0.24, green: 0.82, blue: 0.42)
        case .bloodMoon: return Color(red: 0.92, green: 0.22, blue: 0.24)
        case .sky:       return Color(red: 0.32, green: 0.62, blue: 1.0)
        case .pinky:     return Color(red: 1.0,  green: 0.42, blue: 0.72)
        case .violet:    return Color(red: 0.68, green: 0.42, blue: 1.0)
        }
    }

    var backgroundGradient: LinearGradient {
        LinearGradient(colors: backgroundColors,
                       startPoint: .top,
                       endPoint: .bottom)
    }
}