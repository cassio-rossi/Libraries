# Design System — Tokens Setup

All colors, typography, and spacing live here. Never hardcode values in Views.

---

## Color Tokens

```swift
// DesignSystem/Tokens/Colors.swift
import SwiftUI

extension Color {
    // MARK: - Brand
    static let brandPrimary = Color("BrandPrimary")    // In Assets.xcassets with dark variant
    static let brandSecondary = Color("BrandSecondary")

    // MARK: - Semantic (always prefer over raw colors)
    static let textPrimary = Color("TextPrimary")
    static let textSecondary = Color("TextSecondary")
    static let textDisabled = Color("TextDisabled")

    static let backgroundPrimary = Color("BackgroundPrimary")
    static let backgroundSecondary = Color("BackgroundSecondary")
    static let backgroundCard = Color("BackgroundCard")

    static let borderDefault = Color("BorderDefault")
    static let borderFocused = Color("BorderFocused")

    // MARK: - Status
    static let statusSuccess = Color("StatusSuccess")
    static let statusWarning = Color("StatusWarning")
    static let statusError = Color("StatusError")
    static let statusInfo = Color("StatusInfo")
}
```

Every color has a light + dark variant in Assets.xcassets.

---

## Typography Tokens

```swift
// DesignSystem/Tokens/Typography.swift
import SwiftUI

extension Font {
    // MARK: - Display
    static let displayLarge: Font = .system(.largeTitle, design: .default, weight: .bold)
    static let displayMedium: Font = .system(.title, design: .default, weight: .bold)

    // MARK: - Body
    static let bodyLarge: Font = .system(.body, design: .default, weight: .regular)
    static let bodyMedium: Font = .system(.callout, design: .default, weight: .regular)
    static let bodySmall: Font = .system(.footnote, design: .default, weight: .regular)

    // MARK: - Label
    static let labelLarge: Font = .system(.subheadline, design: .default, weight: .semibold)
    static let labelMedium: Font = .system(.caption, design: .default, weight: .medium)
    static let labelSmall: Font = .system(.caption2, design: .default, weight: .regular)
}
```

Use `.system(TextStyle)` not `.system(size:)` — Dynamic Type scales automatically.

---

## Spacing Tokens

```swift
// DesignSystem/Tokens/Spacing.swift
import CoreGraphics

enum Spacing {
    static let xxSmall: CGFloat = 4
    static let xSmall: CGFloat  = 8
    static let small: CGFloat   = 12
    static let medium: CGFloat  = 16
    static let large: CGFloat   = 24
    static let xLarge: CGFloat  = 32
    static let xxLarge: CGFloat = 48
}

enum Radius {
    static let small: CGFloat   = 8
    static let medium: CGFloat  = 12
    static let large: CGFloat   = 16
    static let full: CGFloat    = 9999  // pill / circle shape
}
```

---

## Usage in Views

```swift
struct ProductCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xSmall) {
            Text("Product Name")
                .font(.labelLarge)
                .foregroundStyle(.textPrimary)

            Text("$9.99")
                .font(.bodyLarge)
                .foregroundStyle(.textSecondary)
        }
        .padding(Spacing.medium)
        .background(.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: Radius.medium))
    }
}
```
