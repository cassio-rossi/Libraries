# Protocol-Oriented Design — SOLID in Swift

---

## Single Responsibility + Dependency Inversion

```swift
// ✅ Each protocol has one job; classes depend on protocols not concretes

protocol UserFetching: Sendable {
    func fetchUser(id: String) async throws -> UserProfile
}

protocol UserUpdating: Sendable {
    func updateUser(_ profile: UserProfile) async throws
}

// Combine only where it makes sense (ISP: don't force implementors to implement unneeded methods)
typealias UserRepository = UserFetching & UserUpdating

final class ProfileViewModel {
    private let fetcher: UserFetching  // depends on protocol, not impl

    init(fetcher: UserFetching) {
        self.fetcher = fetcher
    }
}
```

---

## Open/Closed — extend via protocol default implementations

```swift
// Define the contract
protocol Loggable {
    var logCategory: String { get }
}

// Default implementation — all conformers get this for free
extension Loggable {
    func log(_ message: String) {
        Logger(category: logCategory).info(message)
    }

    func logError(_ error: Error) {
        Logger(category: logCategory).error(error.localizedDescription)
    }
}

// Conforming types get logging for free
final class ProfileViewModel: Loggable {
    var logCategory: String { "ProfileViewModel" }

    func fetch() async throws -> UserProfile {
        log("Starting profile fetch")  // free from extension
        // ...
    }
}
```

---

## Liskov Substitution — all protocol conformances are truly substitutable

```swift
protocol NetworkProtocol: Sendable {
    func get(url: URL) async throws -> Data
}

// Both implementations must honour the contract
final class ProductionNetwork: NetworkProtocol { ... }
final class MockNetwork: NetworkProtocol {
    var stubbedData: Data = Data()
    func get(url: URL) async throws -> Data { stubbedData }  // no surprise throws
}

// Works with either:
let repo = UserRepository(network: ProductionNetwork())
let testRepo = UserRepository(network: MockNetwork())  // fully substitutable
```

---

## Interface Segregation — small, focused protocols

```swift
// ❌ Fat protocol — implementors are forced to stub unused methods
protocol UserService {
    func fetchUser(id: String) async throws -> UserProfile
    func updateUser(_ profile: UserProfile) async throws
    func deleteUser(id: String) async throws
    func fetchFollowers(userId: String) async throws -> [UserProfile]
    func sendMessage(to userId: String, text: String) async throws
}

// ✅ Split by responsibility
protocol UserReading: Sendable {
    func fetchUser(id: String) async throws -> UserProfile
    func fetchFollowers(userId: String) async throws -> [UserProfile]
}

protocol UserWriting: Sendable {
    func updateUser(_ profile: UserProfile) async throws
    func deleteUser(id: String) async throws
}

protocol Messaging: Sendable {
    func sendMessage(to userId: String, text: String) async throws
}
```

---

## DRY via generic constrained extension

```swift
// Instead of writing the same "map array of DTOs to domain" logic in every repository:

extension Collection {
    func mapToDomain<Domain, DTO: DomainConvertible>(
        _ type: Domain.Type
    ) throws -> [Domain] where Element == DTO, DTO.DomainType == Domain {
        try map { try $0.toDomain() }
    }
}

protocol DomainConvertible {
    associatedtype DomainType
    func toDomain() throws -> DomainType
}

// Every DTO that conforms gets mapToDomain for free:
extension UserDTO: DomainConvertible {
    func toDomain() throws -> UserProfile { ... }
}

let profiles = try dtos.mapToDomain(UserProfile.self)
```
