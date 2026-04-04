# Generic Reuse Patterns

---

## Generic paginated list state

```swift
// Reusable pagination state — works for any resource
@Observable
@MainActor
final class PaginatedViewModel<Item: Identifiable & Sendable> {
    var items: [Item] = []
    var isLoading = false
    var hasMore = true
    var errorMessage: String?

    private var currentPage = 1
    private let pageSize: Int
    private let fetcher: @Sendable (Int, Int) async throws -> [Item]

    init(pageSize: Int = 20, fetcher: @escaping @Sendable (Int, Int) async throws -> [Item]) {
        self.pageSize = pageSize
        self.fetcher = fetcher
    }

    func loadMore() async {
        guard !isLoading && hasMore else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let page = try await fetcher(currentPage, pageSize)
            items.append(contentsOf: page)
            hasMore = page.count == pageSize
            currentPage += 1
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func refresh() async {
        items = []
        currentPage = 1
        hasMore = true
        await loadMore()
    }
}

// Usage — no boilerplate per feature
let feedVM = PaginatedViewModel<FeedItem>(pageSize: 20) { page, size in
    try await feedAPI.fetchFeed(page: page, pageSize: size)
}
```

---

## Generic async state wrapper

```swift
enum AsyncState<T: Sendable>: Sendable {
    case idle
    case loading
    case success(T)
    case failure(Error)

    var value: T? {
        if case .success(let v) = self { return v }
        return nil
    }

    var error: Error? {
        if case .failure(let e) = self { return e }
        return nil
    }

    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
}

// ViewModel usage
@Observable @MainActor
final class ProfileViewModel {
    var profileState: AsyncState<UserProfile> = .idle

    func fetch(id: String) async {
        profileState = .loading
        do {
            profileState = .success(try await useCase.execute(id: id))
        } catch {
            profileState = .failure(error)
        }
    }
}

// View usage
switch viewModel.profileState {
case .idle, .loading: ProgressView()
case .success(let profile): ProfileContent(profile: profile)
case .failure(let error): ErrorView(message: error.localizedDescription)
}
```

---

## Generic repository cache

```swift
// In-memory TTL cache — reusable across repositories
final class TTLCache<Key: Hashable, Value: Sendable>: @unchecked Sendable {
    private var store: [Key: (value: Value, expiresAt: Date)] = [:]
    private let ttl: TimeInterval
    private let lock = NSLock()

    init(ttl: TimeInterval = 300) { self.ttl = ttl }  // 5 min default

    func get(_ key: Key) -> Value? {
        lock.withLock {
            guard let entry = store[key], entry.expiresAt > Date() else {
                store.removeValue(forKey: key)
                return nil
            }
            return entry.value
        }
    }

    func set(_ value: Value, for key: Key) {
        lock.withLock {
            store[key] = (value, Date().addingTimeInterval(ttl))
        }
    }

    func invalidate(_ key: Key) {
        lock.withLock { store.removeValue(forKey: key) }
    }

    func invalidateAll() {
        lock.withLock { store.removeAll() }
    }
}

// Usage in repository
private let cache = TTLCache<String, UserProfile>(ttl: 120)

func fetchUser(id: String) async throws -> UserProfile {
    if let cached = cache.get(id) { return cached }
    let profile = try await api.fetchUser(id: id)
    cache.set(profile, for: id)
    return profile
}
```
