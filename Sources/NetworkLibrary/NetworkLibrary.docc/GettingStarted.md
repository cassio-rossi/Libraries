# Getting Started with NetworkLibrary

Learn how to integrate and use NetworkLibrary for API communication in your Swift projects.

## Overview

NetworkLibrary provides a straightforward interface for making HTTP requests with support for different environments, mocking, and comprehensive error handling. It uses Swift's async/await for clean, readable asynchronous code.

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

Initialize the network layer with optional logging:

```swift
import NetworkLibrary
import LoggerLibrary

// Basic initialization
let network = NetworkAPI()

// With logging for debugging
let logger = Logger(category: "Network")
let network = NetworkAPI(logger: logger)
```

### Making a GET Request

Fetch data from an API endpoint:

```swift
// Define your endpoint
let customHost = CustomHost(
    host: "api.example.com",
    path: "/v1",
    api: "/users"
)
let endpoint = Endpoint(customHost: customHost, api: "/users")

// Make the request
do {
    let data = try await network.get(url: endpoint.url)

    // Decode the response
    let users = try JSONDecoder().decode([User].self, from: data)
    print("Fetched \(users.count) users")
} catch {
    print("Request failed: \(error)")
}
```

### Making a POST Request

Send data to an API endpoint:

```swift
struct CreateUserRequest: Codable {
    let name: String
    let email: String
}

let customHost = CustomHost(
    host: "api.example.com",
    path: "/v1"
)
let endpoint = Endpoint(customHost: customHost, api: "/users")

let newUser = CreateUserRequest(name: "John Doe", email: "john@example.com")
let requestBody = try JSONEncoder().encode(newUser)

let headers = [
    "Content-Type": "application/json",
    "Authorization": "Bearer YOUR_TOKEN"
]

do {
    let data = try await network.post(
        url: endpoint.url,
        headers: headers,
        body: requestBody
    )

    let user = try JSONDecoder().decode(User.self, from: data)
    print("Created user: \(user.name)")
} catch {
    print("Request failed: \(error)")
}
```

## Environment Configuration

### Setting Up Different Environments

Define configurations for different environments:

```swift
enum Environment {
    case development
    case staging
    case production

    var customHost: CustomHost {
        switch self {
        case .development:
            return CustomHost(
                secure: false,
                host: "localhost",
                port: 8080,
                path: "/api/v1"
            )
        case .staging:
            return CustomHost(
                host: "staging-api.example.com",
                path: "/v1"
            )
        case .production:
            return CustomHost(
                host: "api.example.com",
                path: "/v1"
            )
        }
    }
}

// Use in your app
let environment = Environment.production
let network = NetworkAPI(customHost: environment.customHost)
```

### Using Query Parameters

Add query parameters to your requests:

```swift
let queryItems = [
    URLQueryItem(name: "page", value: "1"),
    URLQueryItem(name: "limit", value: "20"),
    URLQueryItem(name: "sort", value: "name")
]

let customHost = CustomHost(
    host: "api.example.com",
    path: "/v1"
)

let endpoint = Endpoint(
    customHost: customHost,
    api: "/users",
    queryItems: queryItems
)

// URL will be: https://api.example.com/v1/users?page=1&limit=20&sort=name
let data = try await network.get(url: endpoint.url)
```

## Mocking Responses

### Setting Up Mock Data

Create JSON files for testing:

**users.json:**
```json
[
    {
        "id": 1,
        "name": "John Doe",
        "email": "john@example.com"
    },
    {
        "id": 2,
        "name": "Jane Smith",
        "email": "jane@example.com"
    }
]
```

### Using Mock Data

Configure the network layer to use mock responses:

```swift
let mockData = [
    NetworkMockData(
        api: "/v1/users",
        filename: "users",
        bundle: .main
    )
]

let network = NetworkAPI(mock: mockData)

// This will load data from users.json instead of making a real request
let data = try await network.get(url: endpoint.url)
```

### Environment-Based Mocking

Use environment variables for flexible mocking:

```swift
// Set environment variable: /v1/users=users
// The network layer will automatically load users.json

let network = NetworkAPI()
let data = try await network.get(url: endpoint.url)
// Loads from users.json if environment variable is set
// Otherwise makes a real network request
```

## Error Handling

### Handling Network Errors

NetworkLibrary provides comprehensive error types:

```swift
do {
    let data = try await network.get(url: endpoint.url)
    // Process data
} catch NetworkAPIError.noNetwork {
    showAlert("No network connection. Please check your internet.")
} catch NetworkAPIError.network {
    showAlert("Failed to fetch data from the server.")
} catch NetworkAPIError.decoding {
    showAlert("Failed to decode the response.")
} catch NetworkAPIError.error(let reason) {
    if let errorData = reason,
       let errorMessage = String(data: errorData, encoding: .utf8) {
        showAlert("Server error: \(errorMessage)")
    }
} catch {
    showAlert("An unexpected error occurred: \(error.localizedDescription)")
}
```

### Checking Network Availability

Verify network connectivity before making requests:

```swift
let pingURL = URL(string: "https://api.example.com")!

do {
    try await network.ping(url: pingURL)
    // Network is available, proceed with requests
    let data = try await network.get(url: endpoint.url)
} catch {
    // Network is unavailable
    showAlert("Cannot reach the server. Please check your connection.")
}
```

## Advanced Usage

### Custom Headers

Add authentication and custom headers:

```swift
var headers = [String: String]()
headers["Authorization"] = "Bearer \(accessToken)"
headers["Content-Type"] = "application/json"
headers["X-API-Version"] = "2.0"
headers["Accept-Language"] = Locale.current.languageCode ?? "en"

let data = try await network.get(url: endpoint.url, headers: headers)
```

### Loading Local JSON Files

Load data from bundle resources:

```swift
// Load from main bundle
let fileURL = URL(string: "file:///users.json")!
let data = try network.get(file: fileURL, bundle: .main)

// Or use the load method directly
let data = try network.load(file: "users", bundle: .main)

let users = try JSONDecoder().decode([User].self, from: data)
```

### Protocol-Oriented Testing

Create a mock network implementation for testing:

```swift
class MockNetwork: Network {
    var customHost: CustomHost?
    var mock: [NetworkMockData]?

    var shouldFail = false
    var responseData: Data?

    func get(url: URL, headers: [String: String]?) async throws -> Data {
        if shouldFail {
            throw NetworkAPIError.network
        }
        return responseData ?? Data()
    }

    func post(url: URL, headers: [String: String]?, body: Data) async throws -> Data {
        if shouldFail {
            throw NetworkAPIError.network
        }
        return responseData ?? Data()
    }

    func ping(url: URL) async throws {
        if shouldFail {
            throw NetworkAPIError.noNetwork
        }
    }
}

// Use in tests
func testUserFetch() async throws {
    let mockNetwork = MockNetwork()
    mockNetwork.responseData = try JSONEncoder().encode([User(...)])

    let viewModel = UserViewModel(network: mockNetwork)
    await viewModel.fetchUsers()

    XCTAssertEqual(viewModel.users.count, 1)
}
```

### Using NetworkFailed for Testing

Test failure scenarios with the provided mock:

```swift
let failedNetwork = NetworkFailed()

// All requests will throw NetworkAPIError.network
do {
    let data = try await failedNetwork.get(url: endpoint.url)
} catch NetworkAPIError.network {
    // Expected error
    print("Request failed as expected")
}
```

## SwiftUI Integration

### ViewModel with NetworkLibrary

```swift
import SwiftUI
import NetworkLibrary
import Combine

@MainActor
class UsersViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let network: Network
    private let customHost: CustomHost

    init(network: Network = NetworkAPI()) {
        self.network = network
        self.customHost = CustomHost(
            host: "api.example.com",
            path: "/v1"
        )
    }

    func fetchUsers() async {
        isLoading = true
        errorMessage = nil

        let endpoint = Endpoint(customHost: customHost, api: "/users")

        do {
            let data = try await network.get(url: endpoint.url)
            users = try JSONDecoder().decode([User].self, from: data)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
```

### SwiftUI View

```swift
struct UsersView: View {
    @StateObject private var viewModel = UsersViewModel()

    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading users...")
                } else if let error = viewModel.errorMessage {
                    VStack {
                        Text("Error: \(error)")
                        Button("Retry") {
                            Task {
                                await viewModel.fetchUsers()
                            }
                        }
                    }
                } else {
                    List(viewModel.users) { user in
                        VStack(alignment: .leading) {
                            Text(user.name)
                                .font(.headline)
                            Text(user.email)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Users")
            .task {
                await viewModel.fetchUsers()
            }
        }
    }
}
```

## Best Practices

### Use Dependency Injection

Inject the network instance for testability:

```swift
class UserService {
    private let network: Network

    init(network: Network = NetworkAPI()) {
        self.network = network
    }

    func fetchUser(id: Int) async throws -> User {
        let customHost = CustomHost(host: "api.example.com", path: "/v1")
        let endpoint = Endpoint(customHost: customHost, api: "/users/\(id)")

        let data = try await network.get(url: endpoint.url)
        return try JSONDecoder().decode(User.self, from: data)
    }
}
```

### Centralize Endpoint Configuration

Create a dedicated endpoints manager:

```swift
struct APIEndpoints {
    let customHost: CustomHost

    init(environment: Environment = .production) {
        self.customHost = environment.customHost
    }

    func users(page: Int = 1, limit: Int = 20) -> Endpoint {
        let queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        return Endpoint(customHost: customHost, api: "/users", queryItems: queryItems)
    }

    func user(id: Int) -> Endpoint {
        Endpoint(customHost: customHost, api: "/users/\(id)")
    }

    func createUser() -> Endpoint {
        Endpoint(customHost: customHost, api: "/users")
    }
}

// Usage
let api = APIEndpoints()
let data = try await network.get(url: api.users(page: 1).url)
```

### Handle Errors Gracefully

Provide meaningful feedback to users:

```swift
func fetchData() async {
    do {
        let data = try await network.get(url: endpoint.url)
        // Process data
    } catch NetworkAPIError.noNetwork {
        showUserMessage("No internet connection")
    } catch NetworkAPIError.network {
        showUserMessage("Server error. Please try again.")
    } catch {
        showUserMessage("Something went wrong")
        logError(error) // Log for debugging
    }
}
```

### Use Logging in Development

Enable logging for debugging:

```swift
#if DEBUG
let logger = Logger(category: "Network")
let network = NetworkAPI(logger: logger)
#else
let network = NetworkAPI()
#endif
```

## Troubleshooting

### Requests Timing Out

- Check network connectivity
- Verify the host and endpoint are correct
- Ensure firewall or security settings allow the connection
- Check if the server is responsive

### SSL Certificate Issues

NetworkLibrary handles SSL challenges by default. For custom certificate validation, extend `URLSessionDelegate` methods.

### Mock Data Not Loading

- Verify the JSON file is in the bundle
- Check the filename matches (without .json extension)
- Ensure the API path matches exactly
- Confirm the bundle parameter is correct

### Decoding Errors

- Verify JSON structure matches your Codable models
- Check date formatting if using dates
- Use custom `JSONDecoder` with appropriate strategies
- Print the raw JSON for debugging

## Next Steps

- Explore ``Network`` protocol for custom implementations
- Review ``NetworkAPI`` for the complete API
- Check ``Endpoint`` for URL construction details
- See ``NetworkAPIError`` for error handling
