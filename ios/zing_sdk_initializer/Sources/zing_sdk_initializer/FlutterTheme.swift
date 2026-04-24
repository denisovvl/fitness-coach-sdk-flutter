import UIKit
import DesignSystem

struct FlutterTheme {
    private let customFontFamily = "CustomFontFamily"

    let arguments: [String: Any]

    func build() -> DesignSystem.Theme {
        DesignSystem.Theme(
            colors: colorsProvider(),
            cornersRounding: nil,
            typography: nil,
            assets: nil
        )
    }

    private func colorsProvider() -> TokenProvider<ColorToken, UIColor>? {
        guard let rawColors = arguments["colors"] as? [String: Any] else {
            return nil
        }

        let colors = rawColors
            .compactMapValues { $0 as? Int }
            .filter { ColorToken(token: $0.key) != nil }
            .mapValues(UIColor.init(argb:))

        return TokenProvider { colors[$0.token] }
    }

    private func cornersRoundingProvider() {
    }

    private func typographyProvider() {
    }

    private func assetsProvider() {
    }
}

private extension UIColor {
    convenience init(argb: Int) {
        let a = CGFloat((argb >> 24) & 0xFF) / 255.0
        let r = CGFloat((argb >> 16) & 0xFF) / 255.0
        let g = CGFloat((argb >> 8) & 0xFF) / 255.0
        let b = CGFloat(argb & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}
