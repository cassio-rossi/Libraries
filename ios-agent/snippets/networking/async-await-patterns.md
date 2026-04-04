# Async/Await Patterns in Swift

---

## Basic async function

```swift
func fetchProfile(id: String) async throws -> UserProfile {
    let data = try await network.get(url: endpoint.url)
    return try data.asObject()
}
```

---

## @MainActor ViewModel with async task

```swift
@Observable
@MainActor
final class ProfileViewModel {
    var profile: UserProfile?
    var isLoading = false
    var errorMessage: String?

    private let useCase: FetchProfileUseCaseProtocol

    init(useCase: FetchProfileUseCaseProtocol) {
        self.useCase = useCase
    }

    func fetchProfile(id: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            profile = try await useCase.execute(id: id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
```

---

## SwiftUI View calling async work

```swift
struct ProfileView: View {
    @State private var viewModel: ProfileViewModel

    var body: some View {
        content
            .task {
                // task {} is tied to the view's lifecycle — auto-cancelled on disappear
                await viewModel.fetchProfile(id: "me")
            }
    }
}
```

Use `.task { }` not `.onAppear { Task { } }` — the latter leaks.

---

## Parallel fetches with async let

```swift
func loadDashboard() async throws -> Dashboard {
    async let profile = profileAPI.fetchProfile()
    async let feed = feedAPI.fetchFeed(page: 1)
    async let notifications = notificationAPI.fetchUnread()

    return try await Dashboard(
        profile: profile,
        feed: feed,
        notifications: notifications
    )
}
```

---

## Task group for dynamic parallelism

```swift
func fetchAllUsers(ids: [String]) async throws -> [UserProfile] {
    try await withThrowingTaskGroup(of: UserProfile.self) { group in
        for id in ids {
            group.addTask { try await self.fetchUser(id: id) }
        }
        var results: [UserProfile] = []
        for try await user in group {
            results.append(user)
        }
        return results
    }
}
```

---

## Cancellation-aware work

```swift
func longRunningTask() async throws -> Result {
    for item in items {
        try Task.checkCancellation()  // throws CancellationError if task cancelled
        await process(item)
    }
    return result
}
```

---

## Actor for shared mutable state

```swift
actor ImageCache {
    private var cache: [URL: Data] = [:]

    func image(for url: URL) -> Data? { cache[url] }

    func store(_ data: Data, for url: URL) { cache[url] = data }
}
```

Use `actor` instead of `DispatchQueue` + locks for protecting shared state.
