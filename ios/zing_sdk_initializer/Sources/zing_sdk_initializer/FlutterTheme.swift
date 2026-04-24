import UIKit
import DesignSystem

struct FlutterTheme {
    private let customFontFamily = "CustomFontFamily"

    let arguments: [String: Any]

    func build() -> DesignSystem.Theme {
        DesignSystem.Theme(
            colors: colorsProvider(),
            cornersRounding: cornersRoundingProvider(),
            typography: typographyProvider(),
            assets: assetsProvider()
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

    private func cornersRoundingProvider() -> TokenProvider<RadiusToken, RadiusAttribute>? {
        guard let rawCornersRounding = arguments["cornersRounding"] as? [String: Any] else {
            return nil
        }

        let cornersRounding = rawCornersRounding
            .compactMapValues { $0 as? [String: Any] }
            .filter { RadiusToken(token: $0.key) != nil }
            .compactMapValues(RadiusAttribute.init(entry:))

        return TokenProvider { cornersRounding[$0.token] }
    }

    private func typographyProvider() -> TokenProvider<TypographyToken, TypographyAttributes>? {
        guard UIFont.familyNames.contains(customFontFamily) else {
            return nil
        }

        return TokenProvider { _ in
            TypographyAttributes(fontFamily: customFontFamily)
        }
    }

    private func assetsProvider() -> TokenProvider<AssetToken, UIImage> {
        TokenProvider { UIImage(named: $0.token) }
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
