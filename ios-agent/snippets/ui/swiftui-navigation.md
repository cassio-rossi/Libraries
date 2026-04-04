# SwiftUI Navigation Patterns

---

## NavigationStack (iOS 16+, preferred)

```swift
// Always use NavigationStack, never NavigationView
NavigationStack(path: $coordinator.path) {
    HomeView()
        .navigationDestination(for: AppRoute.self) { route in
            switch route {
            case .profile(let id): ProfileView(userId: id)
            case .settings: SettingsView()
            }
        }
}
```

---

## Sheet presentation

```swift
// Simple sheet
.sheet(isPresented: $showSettings) {
    NavigationStack {
        SettingsView()
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { showSettings = false }
                }
            }
    }
}

// Sheet with result callback
.sheet(item: $selectedUser) { user in
    EditUserView(user: user) { updated in
        viewModel.handleUpdate(updated)
    }
}
```

---

## Full screen cover

```swift
.fullScreenCover(isPresented: $showOnboarding) {
    OnboardingFlow()
}
```

---

## Confirmation dialog (iOS 15+)

```swift
.confirmationDialog("Delete this item?", isPresented: $showDeleteConfirmation) {
    Button("Delete", role: .destructive) {
        Task { await viewModel.delete() }
    }
    Button("Cancel", role: .cancel) { }
} message: {
    Text("This action cannot be undone.")
}
```

---

## Alert

```swift
.alert("Error", isPresented: $showError, presenting: viewModel.error) { _ in
    Button("OK") { viewModel.clearError() }
} message: { error in
    Text(error.localizedDescription)
}
```

---

## Deep link handling

```swift
// App/Navigation/AppCoordinatorView.swift
.onOpenURL { url in
    if let route = AppRoute(from: url) {
        coordinator.push(route)
    }
}

// AppRoute+DeepLink.swift
extension AppRoute {
    init?(from url: URL) {
        guard url.scheme == "myapp" else { return nil }
        switch url.host {
        case "profile": self = .profile(userId: url.lastPathComponent)
        case "settings": self = .settings
        default: return nil
        }
    }
}
```
