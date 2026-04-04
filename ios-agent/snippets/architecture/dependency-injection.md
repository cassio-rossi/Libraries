# Dependency Injection — App Container Pattern

No singletons in feature code. No `ServiceLocator.shared`. Only `init`-based injection.
The DI container is the **only** place that instantiates concrete types.

---

## App Container

```swift
// App/DI/AppContainer.swift
import NetworkLibrary
import StorageLibrary
import LoggerLibrary

/// Root dependency container. Created once in @main App struct.
/// Pass sub-containers (or individual dependencies) into feature roots.
@MainActor
final class AppContainer {

    // MARK: - Infrastructure

    let logger = Logger(category: "App")

    lazy var network: Network & Sendable = NetworkFactory.make(
        logger: logger,
        host: APIHost.production
    )

    lazy var storage: Storage = DefaultStorage(nil)
    lazy var secureStorage = SecureStorage(service: Bundle.main.bundleIdentifier)

    // MARK: - Feature Containers

    lazy var profileContainer = ProfileContainer(network: network, storage: storage)
    lazy var authContainer = AuthContainer(network: network, secureStorage: secureStorage)
}

// App/DI/ProfileContainer.swift
@MainActor
final class ProfileContainer {
    private let network: Network & Sendable
    private let storage: Storage

    init(network: Network & Sendable, storage: Storage) {
        self.network = network
        self.storage = storage
    }

    func makeViewModel() -> ProfileViewModel {
        ProfileViewModel(
            fetchProfileUseCase: FetchProfileUseCase(
                repository: ProfileRepositoryImpl(
                    api: ProfileAPI(network: network),
                    storage: storage
                )
            )
        )
    }
}
```

---

## Wiring in @main

```swift
// App/MyApp.swift
import SwiftUI

@main
struct MyApp: App {
    @State private var container = AppContainer()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(container)
        }
    }
}
```

---

## Passing container to views

```swift
// Features/Profile/Presentation/Views/ProfileView.swift
struct ProfileView: View {
    @Environment(AppContainer.self) private var container
    @State private var viewModel: ProfileViewModel?

    var body: some View {
        content
            .task {
                viewModel = container.profileContainer.makeViewModel()
                await viewModel?.onAppear(userId: "me")
            }
    }
}
```

Or pass ViewModel directly from parent (preferred for testability):
```swift
NavigationLink {
    ProfileView(viewModel: container.profileContainer.makeViewModel())
} label: {
    Text("Profile")
}
```

---

## Mock container for Previews / Tests

```swift
// App/DI/MockAppContainer.swift  (DEBUG only)
#if DEBUG
@MainActor
final class MockAppContainer: AppContainer {
    override lazy var network: Network & Sendable = NetworkFactory.make(
        mapper: MockData.all
    )
}
#endif

// In a Preview:
#Preview {
    ProfileView(viewModel: MockAppContainer().profileContainer.makeViewModel())
        .environment(MockAppContainer())
}
```
