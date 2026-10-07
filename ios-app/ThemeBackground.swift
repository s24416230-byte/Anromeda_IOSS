import SwiftUI
import UIKit

/// Global window background for SwiftUI TabView. Sets the gradient
/// below all UIKit layers so it shows through every tab and ScrollView.
final class ThemeBackground {
    static let shared = ThemeBackground()

    private var window: UIWindow?

    func setTheme(_ theme: AppTheme) {
        DispatchQueue.main.async {
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = scene.windows.first else { return }

            if let existing = window.viewWithTag(0xDEADBEEF) {
                existing.removeFromSuperview()
            }

            let gradientView = UIView(frame: window.bounds)
            gradientView.tag = 0xDEADBEEF
            gradientView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

            let gradient = CAGradientLayer()
            gradient.frame = gradientView.bounds
            gradient.colors = theme.backgroundColors.map { UIColor($0).cgColor }
            gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
            gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
            gradientView.layer.addSublayer(gradient)

            // Insert at the very bottom of the window's view hierarchy
            window.insertSubview(gradientView, at: 0)
            self.window = window
        }
    }
}