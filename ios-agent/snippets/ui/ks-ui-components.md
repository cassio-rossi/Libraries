# KSLibrary UIComponentsLibrary — Component Reference

Import: `import UIComponents`

---

## CachedAsyncImage

Loads and caches remote images via Kingfisher. Prefer over native `AsyncImage`.

```swift
// Basic usage — aspect fit, Kingfisher-backed
CachedAsyncImage(image: imageURL)
    .frame(width: 80, height: 80)
    .clipShape(RoundedRectangle(cornerRadius: 8))

// Native AsyncImage (usesNative: true) — no Kingfisher dependency
CachedAsyncImage(image: imageURL, usesNative: true, contentMode: .fill)
    .frame(width: 200, height: 120)
    .clipped()
```

`init(image: URL, usesNative: Bool = false, contentMode: ContentMode = .fit)`

---

## CircularProgressView

Animated ring progress indicator.

```swift
CircularProgressView(progress: 0.75, lineWidth: 10, color: .blue)
    .frame(width: 60, height: 60)

// Compact inline version
CircularProgressView(progress: viewModel.downloadProgress, lineWidth: 4, color: .accentColor)
    .frame(width: 24, height: 24)
```

`init(progress: Double, lineWidth: CGFloat = 20, color: Color)`

---

## ErrorView

Inline error message with fade-in animation. Returns `nil` when message is `nil` — safe to use directly.

```swift
// Inline field error
ErrorView(message: viewModel.emailError)

// Custom alignment
ErrorView(message: viewModel.formError, position: .center, color: .orange)

// Safe nil handling — view doesn't appear when message is nil
if let errorView = ErrorView(message: viewModel.errorMessage) {
    errorView
}
```

`init?(message: String?, position: Position = .left, color: Color = .red)`

---

## LottieView

Lottie animation player. Use for loading, success, empty states.

```swift
// Define your assets (conform to LottieAsset protocol)
enum AppAnimation: String, LottieAsset {
    case loading = "loading_spinner"
    case success = "checkmark_success"
    case empty = "empty_state"
}

// Usage
LottieView(asset: AppAnimation.loading, loopMode: .loop)
    .frame(width: 120, height: 120)

LottieView(asset: AppAnimation.success, loopMode: .playOnce)
    .frame(width: 80, height: 80)
```

---

## SearchBar

Custom search bar with binding.

```swift
@State private var searchText = ""

SearchBar(text: $searchText, placeholder: "Search videos...")
    .padding(.horizontal)

// Filter list based on search
let filtered = items.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
```

---

## AvatarView

Circular user avatar with fallback initials.

```swift
AvatarView(url: user.avatarURL, name: user.displayName, size: 44)

// Without URL (initials fallback)
AvatarView(url: nil, name: "Alice Smith", size: 36)
```

---

## PDFViewer

Full-featured PDF viewer.

```swift
PDFViewer(url: documentURL)
    .ignoresSafeArea()

// In a sheet
.sheet(isPresented: $showPDF) {
    NavigationStack {
        PDFViewer(url: pdfURL)
            .navigationTitle("Document")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { showPDF = false }
                }
            }
    }
}
```

---

## WebView

WKWebView wrapper for in-app browsing.

```swift
Webview(url: termsURL)

// With cache policy
Webview(url: articleURL, cachePolicy: .returnCacheDataElseLoad)
```

---

## Alerts

```swift
// System alert with dismiss handler
Alerts.show(title: "Error", message: error.localizedDescription)

// Confirmation alert
Alerts.confirm(
    title: "Delete Account",
    message: "This action cannot be undone.",
    confirmTitle: "Delete",
    onConfirm: { await viewModel.deleteAccount() }
)
```

---

## Buttons (new style)

```swift
// Primary CTA
PrimaryButton(title: "Get Started") {
    coordinator.push(.onboarding)
}

// Secondary
SecondaryButton(title: "Learn More") { }

// Destructive
DestructiveButton(title: "Delete") {
    await viewModel.delete()
}
```

---

## RequestReview

Trigger an App Store review prompt.

```swift
RequestReview.ask()  // Shows review prompt (respects Apple's rate limiting)
```

---

## View Extensions (UIComponentsLibrary)

```swift
// Corner radius with specific corners
.cornerRadius(12, corners: [.topLeft, .topRight])

// Card shadow
.cardShadow()

// Full-screen cover with custom transition
.fullScreenCover(isPresented: $showWelcome) {
    WelcomeView()
}

// Loading + error composite view
LoadingAndErrorView(
    isLoading: viewModel.isLoading,
    error: viewModel.errorMessage
) {
    // Content shown when not loading and no error
    FeedList()
}
```
