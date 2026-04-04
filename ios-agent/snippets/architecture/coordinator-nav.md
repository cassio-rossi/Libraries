# Coordinator Navigation — NavigationStack Pattern

Use `NavigationStack` with a typed path for programmatic navigation.
No `NavigationLink(destination:)` scattered across views.

---

## Route enum

```swift
// App/Navigation/AppRoute.swift
enum AppRoute: Hashable {
    case profile(userId: String)
    case settings
    case editProfile(UserProfile)
    case onboarding
}
```

---

## App Coordinator ViewModel

```swift
// App/Navigation/AppCoordinatorViewModel.swift
import Observation

@Observable
@MainActor
final class AppCoordinatorViewModel {
    var path: [AppRoute] = []
    var presentedSheet: AppRoute?
    var presentedFullScreen: AppRoute?

    func push(_ route: AppRoute) {
        path.append(route)
    }

    func pop() {
        path.removeLast()
    }

    func popToRoot() {
        path.removeAll()
    }

    func present(_ route: AppRoute, style: PresentationStyle = .sheet) {
        switch style {
        case .sheet: presentedSheet = route
        case .fullScreen: presentedFullScreen = route
        }
    }

    func dismiss() {
        presentedSheet = nil
        presentedFullScreen = nil
    }

    enum PresentationStyle {
        case sheet, fullScreen
    }
}
```

---

## Root View wiring

```swift
// App/Navigation/AppCoordinatorView.swift
struct AppCoordinatorView: View {
    @State private var coordinator = AppCoordinatorViewModel()
    @Environment(AppContainer.self) private var container

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            HomeView()
                .navigationDestination(for: AppRoute.self) { route in
                    destination(for: route)
                }
        }
        .sheet(item: $coordinator.presentedSheet) { route in
            destination(for: route)
        }
        .fullScreenCover(item: $coordinator.presentedFullScreen) { route in
            destination(for: route)
        }
        .environment(coordinator)
    }

    @ViewBuilder
    private func destination(for route: AppRoute) -> some View {
        switch route {
        case .profile(let userId):
            ProfileView(viewModel: container.profileContainer.makeViewModel(userId: userId))
        case .settings:
            SettingsView()
        case .editProfile(let profile):
            EditProfileView(profile: profile)
        case .onboarding:
            OnboardingView()
        }
    }
}
```

---

## Navigating from a View

```swift
struct HomeView: View {
    @Environment(AppCoordinatorViewModel.self) private var coordinator

    var body: some View {
        Button("Open Profile") {
            coordinator.push(.profile(userId: "me"))
        }
        .frame(minWidth: 44, minHeight: 44)  // HIG tap target
    }
}
```

---

## AppRoute must be Hashable

For routes with associated values containing non-Hashable types, use IDs:
```swift
case editProfile(profileId: String)  // store ID, load from DI container
```
