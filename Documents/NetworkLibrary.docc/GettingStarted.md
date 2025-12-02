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

// Using the factory (recommended)
let network = NetworkFactory.make()

// With logging
let logger = Logger(category: "Network")
let network = NetworkFactory.make(logger: logger)

// Direct instantiation (production)
let network = DefaultNetwork()

// With logging (direct)
let network = DefaultNetwork(logger: Logger(category: "Network"))
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

let network = NetworkFactory.make(host: Environment.production.customHost)
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
// For testing - use NetworkMock directly
let mockData = [NetworkMockData(api: "/v1/users", filename: "users")]
let network = NetworkMock(mapper: mockData)
let data = try await network.get(url: endpoint.url)

// Using NetworkFactory (automatically returns NetworkMock in DEBUG with mock data)
#if DEBUG
let mockData = [NetworkMockData(api: "/v1/users", filename: "users")]
let network = NetworkFactory.make(mapper: mockData)
#else
let network = NetworkFactory.make()
#endif
```

### Mock Data with Custom Bundle

When testing with mock JSON files, specify the bundle path:

```swift
let mockData = [
    NetworkMockData(
        api: "/v1/users",
        filename: "users",
        bundlePath: Bundle.module.bundlePath  // For test bundles
    )
]
let network = NetworkMock(mapper: mockData)
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

### Using Mock Data for Testing

```swift
// Mock data automatically loads from JSON files
let mockData = [
    NetworkMockData(api: "/v1/users", filename: "users_mock")
]
let network = NetworkMock(mapper: mockData)

// The network will load "users_mock.json" from the bundle when the API is called
let endpoint = Endpoint(customHost: host, api: "/users")
let data = try await network.get(url: endpoint.url)
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

    init(network: Network = NetworkFactory.make()) {
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

    init(network: Network = NetworkFactory.make()) {
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
let logger = Logger(category: "Network")
let network = NetworkFactory.make(logger: logger)
#else
let network = NetworkFactory.make()
#endif
```

## NetworkFactory vs Direct Instantiation

### Using NetworkFactory (Recommended)

The `NetworkFactory` automatically handles environment configuration:

```swift
// Production - returns DefaultNetwork
let network = NetworkFactory.make()

// Testing with mocks - returns NetworkMock in DEBUG mode
let mockData = [NetworkMockData(api: "/users", filename: "users_mock")]
let network = NetworkFactory.make(mapper: mockData)
```

### Direct Instantiation

For specific use cases, instantiate directly:

```swift
// Production network
let network = DefaultNetwork(logger: logger, customHost: host)

// Mock network for testing
let network = NetworkMock(logger: logger, customHost: host, mapper: mockData)

// Always-failing network for error testing
let network = NetworkFailed()
```
