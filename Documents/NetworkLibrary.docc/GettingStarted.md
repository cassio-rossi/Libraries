# Getting Started with NetworkLibrary

Integrate NetworkLibrary for API communication in your Swift projects.

## Overview

NetworkLibrary provides HTTP requests with environment support, mocking, and error handling using Swift's async/await.

## Installation

Add NetworkLibrary to your project using Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/cassio-rossi/Libraries.git", from: "1.0.0")
]
```

Then add it to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "Network", package: "Libraries")
    ]
)
```

## Basic Usage

### Creating a Network Instance

```swift
import NetworkLibrary

let network = NetworkAPI()

// With logging
let network = NetworkAPI(logger: Logger(category: "Network"))
```

### Making a GET Request

```swift
let host = CustomHost(host: "api.example.com", path: "/v1")
let endpoint = Endpoint(customHost: host, api: "/users")

let data = try await network.get(url: endpoint.url)
let users = try JSONDecoder().decode([User].self, from: data)
```

### Making a POST Request

```swift
let host = CustomHost(host: "api.example.com", path: "/v1")
let endpoint = Endpoint(customHost: host, api: "/users")

let body = try JSONEncoder().encode(newUser)
let headers = ["Content-Type": "application/json"]

let data = try await network.post(url: endpoint.url, headers: headers, body: body)
let user = try JSONDecoder().decode(User.self, from: data)
```

## Environment Configuration

```swift
enum Environment {
    case development, staging, production

    var customHost: CustomHost {
        switch self {
        case .development:
            return CustomHost(secure: false, host: "localhost", port: 8080, path: "/api/v1")
        case .staging:
            return CustomHost(host: "staging-api.example.com", path: "/v1")
        case .production:
            return CustomHost(host: "api.example.com", path: "/v1")
        }
    }
}

let network = NetworkAPI(customHost: Environment.production.customHost)
```

### Query Parameters

```swift
let queryItems = [
    URLQueryItem(name: "page", value: "1"),
    URLQueryItem(name: "limit", value: "20")
]
let endpoint = Endpoint(customHost: host, api: "/users", queryItems: queryItems)
let data = try await network.get(url: endpoint.url)
```

## Mocking Responses

```swift
let mockData = [NetworkMockData(api: "/v1/users", filename: "users")]
let network = NetworkAPI(mock: mockData)
let data = try await network.get(url: endpoint.url)
```

## Error Handling

```swift
do {
    let data = try await network.get(url: endpoint.url)
} catch NetworkAPIError.noNetwork {
    showAlert("No internet connection")
} catch NetworkAPIError.network {
    showAlert("Request failed")
} catch NetworkAPIError.decoding {
    showAlert("Invalid response")
} catch NetworkAPIError.error(let reason) {
    handleServerError(reason)
}
```

### Network Availability

```swift
try await network.ping(url: URL(string: "https://api.example.com")!)
```

## Advanced Usage

### Custom Headers

```swift
let headers = [
    "Authorization": "Bearer \(token)",
    "Content-Type": "application/json"
]
let data = try await network.get(url: endpoint.url, headers: headers)
```

### Loading Local Files

```swift
let data = try network.load(file: "users", bundle: .main)
let users = try JSONDecoder().decode([User].self, from: data)
```

### Testing with NetworkFailed

```swift
func testErrorHandling() async {
    let network = NetworkFailed()
    let viewModel = UserViewModel(network: network)
    await viewModel.fetchUsers()
    XCTAssertNotNil(viewModel.errorMessage)
}
```

## SwiftUI Integration

```swift
@MainActor
class UsersViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let network: Network
    private let host = CustomHost(host: "api.example.com", path: "/v1")

    init(network: Network = NetworkAPI()) {
        self.network = network
    }

    func fetchUsers() async {
        isLoading = true
        errorMessage = nil

        do {
            let endpoint = Endpoint(customHost: host, api: "/users")
            let data = try await network.get(url: endpoint.url)
            users = try JSONDecoder().decode([User].self, from: data)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
```

## Best Practices

### Dependency Injection

```swift
class UserService {
    private let network: Network

    init(network: Network = NetworkAPI()) {
        self.network = network
    }

    func fetchUser(id: Int) async throws -> User {
        let host = CustomHost(host: "api.example.com", path: "/v1")
        let endpoint = Endpoint(customHost: host, api: "/users/\(id)")
        let data = try await network.get(url: endpoint.url)
        return try JSONDecoder().decode(User.self, from: data)
    }
}
```

### Centralize Endpoints

```swift
struct APIEndpoints {
    let host: CustomHost

    func users(page: Int = 1) -> Endpoint {
        Endpoint(customHost: host, api: "/users", queryItems: [
            URLQueryItem(name: "page", value: "\(page)")
        ])
    }

    func user(id: Int) -> Endpoint {
        Endpoint(customHost: host, api: "/users/\(id)")
    }
}

let api = APIEndpoints(host: CustomHost(host: "api.example.com", path: "/v1"))
let data = try await network.get(url: api.users(page: 1).url)
```

### Enable Logging in Debug

```swift
#if DEBUG
let network = NetworkAPI(logger: Logger(category: "Network"))
#else
let network = NetworkAPI()
#endif
```
