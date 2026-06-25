import SwiftUI

enum AppTheme {
    static let accent = Color("AccentColor")
    static let cardCorner: CGFloat = 20
    static let smallCorner: CGFloat = 12
    static let cardSpacing: CGFloat = 12

    static let warmGradient = LinearGradient(
        colors: [Color(red: 0.97, green: 0.50, blue: 0.65), Color(red: 1.0, green: 0.70, blue: 0.45)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )

    static let cool = Color(red: 0.46, green: 0.70, blue: 0.97)
    static let success = Color.green
    static let warning = Color.orange
    static let danger = Color.red
}
