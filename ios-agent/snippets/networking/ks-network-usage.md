# KSLibrary NetworkLibrary — Usage Guide

Import: `import NetworkLibrary`

---

## 1. Define a Host (one per environment)

```swift
// Core/Constants/APIHosts.swift
enum APIHost {
    static let production = CustomHost(
        secure: true,
        host: "api.example.com",
        path: "/v1"
    )

    static let staging = CustomHost(
        secure: true,
        host: "staging.api.example.com",
        path: "/v1"
    )
}
```

`CustomHost` fields: `secure: Bool = true`, `host: String`, `port: Int?`, `path: String?`, `api: String?`, `queryItems: [URLQueryItem]?`

---

## 2. Build Endpoints

```swift
// Features/Users/Data/UserEndpoints.swift
enum UserEndpoints {
    static func list(page: Int) -> Endpoint {
        Endpoint(
            customHost: APIHost.production,
            api: "/users",
            queryItems: [URLQueryItem(name: "page", value: "\(page)")]
        )
    }

    static func detail(id: String) -> Endpoint {
        Endpoint(customHost: APIHost.production, api: "/users/\(id)")
    }
}
```

Access the final URL via `endpoint.url`. Match mock paths with `endpoint.restAPI`.

---

## 3. Network Protocol — always inject this, never DefaultNetwork directly

```swift
// NetworkLibrary already defines:
public protocol Network {
    var customHost: CustomHost? { get }
    func get(url: URL, headers: [String: String]?) async throws -> Data
    func post(url: URL, headers: [String: String]?, body: Data) async throws -> Data
    func ping(url: URL) async throws
}
```

---

## 4. API Client (Repository Data layer)

```swift
// Features/Users/Data/UserAPI.swift
import NetworkLibrary
import UtilityLibrary  // for Data.asObject()

protocol UserAPIProtocol: Sendable {
    func fetchUsers(page: Int) async throws -> [UserDTO]
    func fetchUser(id: String) async throws -> UserDTO
}

final class UserAPI: UserAPIProtocol {
    private let network: Network & Sendable

    init(network: Network & Sendable) {
        self.network = network
    }

    func fetchUsers(page: Int) async throws -> [UserDTO] {
        let data = try await network.get(url: UserEndpoints.list(page: page).url)
        return try data.asObject()  // KSLibrary CodableExtensions
    }

    func fetchUser(id: String) async throws -> UserDTO {
        let data = try await network.get(url: UserEndpoints.detail(id: id).url)
        return try data.asObject()
    }
}
```

---

## 5. Create with NetworkFactory (auto-selects mock in DEBUG)

```swift
// App/DI/Container.swift
import NetworkLibrary
import LoggerLibrary

final class AppContainer {
    static let shared = AppContainer()

    let network: Network & Sendable = NetworkFactory.make(
        logger: Logger(category: "Network"),
        host: APIHost.production
    )
}
```

`NetworkFactory.make()` returns:
- `NetworkMock` in DEBUG when `ProcessInfo.arguments` contains `"mock"` or a mapper is passed.
- `DefaultNetwork` in RELEASE and in DEBUG without mock flags.

---

## 6. Mock for Tests / Previews

```swift
// Resources/Mocks/users.json  ← create this file with sample JSON

// In test or preview:
let mockData = [
    NetworkMockData(api: "/v1/users", filename: "users"),        // → users.json
    NetworkMockData(api: "/v1/users/42", filename: "user_detail") // → user_detail.json
]
let mockNetwork = NetworkFactory.make(mapper: mockData)
let api = UserAPI(network: mockNetwork)
```

`NetworkMockData(api:filename:bundlePath:)` — `bundlePath` defaults to `Bundle.main`.

---

## 7. Error Handling

```swift
// Core/Errors/AppError.swift
enum AppError: LocalizedError {
    case network(reason: String)
    case notFound
    case unauthorized

    var errorDescription: String? {
        switch self {
        case .network(let reason): return reason
        case .notFound: return "Resource not found"
        case .unauthorized: return "Please log in again"
        }
    }
}

// In repository:
do {
    let dto = try await api.fetchUser(id: id)
    return UserProfile(from: dto)
} catch NetworkAPIError.noNetwork {
    throw AppError.network(reason: "No internet connection")
} catch {
    throw AppError.network(reason: error.localizedDescription)
}
```

Never let `NetworkAPIError` leak into the Domain layer — always translate at the repository boundary.

---

## 8. ping() for connectivity check

```swift
func checkConnectivity() async -> Bool {
    do {
        try await network.ping(url: APIHost.production.url!)
        return true
    } catch {
        return false
    }
}
```
