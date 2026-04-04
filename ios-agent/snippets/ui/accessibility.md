# Accessibility — VoiceOver, Dynamic Type, Tap Targets

---

## Minimum tap targets (HIG: 44×44 pt)

```swift
// Always ensure interactive controls meet the minimum
Button(action: { }) {
    Image(systemName: "heart")
}
.frame(minWidth: 44, minHeight: 44)
.contentShape(Rectangle())  // makes the full frame tappable
```

---

## accessibilityLabel and accessibilityHint

```swift
// Every non-text interactive element needs a label
CachedAsyncImage(image: user.avatarURL)
    .accessibilityLabel("\(user.name)'s profile photo")
    .accessibilityHint("Double-tap to view profile")

// For decorative images: hide from VoiceOver
Image("decorativeBanner")
    .accessibilityHidden(true)

// Combine label from multiple text elements
HStack {
    Text(product.name)
    Spacer()
    Text(product.price)
}
.accessibilityElement(children: .combine)
```

---

## Dynamic Type

```swift
// ✅ Always use text styles (scales with user's font size setting)
Text("Hello").font(.body)
Text("Title").font(.headline)

// ❌ Never hardcode font sizes
Text("Hello").font(.system(size: 16))  // Does NOT scale

// For fixed-size containers that need layout adjustment
@ScaledMetric(relativeTo: .body) var iconSize: CGFloat = 24
Image(systemName: "star")
    .font(.system(size: iconSize))
```

---

## Accessibility traits

```swift
Text("Section Header")
    .font(.title3.bold())
    .accessibilityAddTraits(.isHeader)

Button("Submit") { }
    .accessibilityAddTraits(.isButton)

// For tab-like items
Text("Home")
    .accessibilityAddTraits(isSelected ? .isSelected : [])
```

---

## grouping elements

```swift
// Group card content so VoiceOver reads it as one item
VStack(alignment: .leading) {
    Text(article.title).font(.headline)
    Text(article.summary).font(.subheadline).foregroundStyle(.secondary)
    Text(article.publishDate).font(.caption)
}
.accessibilityElement(children: .combine)
.accessibilityLabel("\(article.title). \(article.summary). Published \(article.publishDate).")
```

---

## Reduce motion

```swift
@Environment(\.accessibilityReduceMotion) private var reduceMotion

var body: some View {
    content
        .animation(reduceMotion ? .none : .spring(), value: isExpanded)
}
```

---

## Voice Control (custom actions)

```swift
Image(systemName: "trash")
    .accessibilityLabel("Delete")
    .accessibilityAction {
        viewModel.delete(item)
    }
```
