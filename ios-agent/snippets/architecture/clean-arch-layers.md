# Clean Architecture Layers — Feature Folder Template

Every feature follows this three-layer structure.
**Dependency rule**: inner layers never import outer layers.

```
Features/
└── Profile/
    ├── Domain/
    │   ├── Models/
    │   │   └── UserProfile.swift          ← Pure Swift struct, no framework imports
    │   └── UseCases/
    │       ├── FetchProfileUseCase.swift  ← Protocol + implementation
    │       └── UpdateProfileUseCase.swift
    ├── Data/
    │   ├── DTOs/
    │   │   └── UserDTO.swift              ← Codable, maps to/from API JSON
    │   └── Repositories/
    │       ├── ProfileRepository.swift    ← Protocol (defined in Domain)
    │       └── ProfileRepositoryImpl.swift← Concrete: calls API + storage
    └── Presentation/
        ├── ViewModel/
        │   └── ProfileViewModel.swift     ← @Observable @MainActor
        └── Views/
            ├── ProfileView.swift
            └── ProfileView+Subviews.swift ← Private subviews as extension
```

---

## Domain Model (pure Swift)

```swift
// Features/Profile/Domain/Models/UserProfile.swift
struct UserProfile: Identifiable, Equatable, Sendable {
    let id: String
    let name: String
    let bio: String?
    let avatarURL: URL?
    let createdAt: Date
}
```

No `import Foundation` if you can avoid it. No `@Model`. No `NSManagedObject`.

---

## UseCase

```swift
// Features/Profile/Domain/UseCases/FetchProfileUseCase.swift
protocol FetchProfileUseCaseProtocol: Sendable {
    func execute(userId: String) async throws -> UserProfile
}

final class FetchProfileUseCase: FetchProfileUseCaseProtocol {
    private let repository: ProfileRepositoryProtocol

    init(repository: ProfileRepositoryProtocol) {
        self.repository = repository
    }

    func execute(userId: String) async throws -> UserProfile {
        try await repository.fetchProfile(userId: userId)
    }
}
```

One public method per use case. If you need two operations, create two use cases.

---

## DTO (Data Transfer Object)

```swift
// Features/Profile/Data/DTOs/UserDTO.swift
struct UserDTO: Codable, Sendable {
    let id: String
    let name: String
    let bio: String?
    let avatarUrl: String?     // API uses snake_case — CodingKeys handles conversion
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case id, name, bio
        case avatarUrl = "avatar_url"
        case createdAt = "created_at"
    }
}

extension UserDTO {
    func toDomain() throws -> UserProfile {
        UserProfile(
            id: id,
            name: name,
            bio: bio,
            avatarURL: avatarUrl.flatMap { URL(string: $0) },
            createdAt: ISO8601DateFormatter().date(from: createdAt) ?? .now
        )
    }
}
```

---

## Repository Protocol (Domain) + Implementation (Data)

```swift
// Features/Profile/Domain/UseCases/ProfileRepository.swift (protocol in Domain)
protocol ProfileRepositoryProtocol: Sendable {
    func fetchProfile(userId: String) async throws -> UserProfile
    func updateProfile(_ profile: UserProfile) async throws
}

// Features/Profile/Data/Repositories/ProfileRepositoryImpl.swift
import NetworkLibrary

final class ProfileRepositoryImpl: ProfileRepositoryProtocol {
    private let api: ProfileAPIProtocol
    private let storage: Storage

    init(api: ProfileAPIProtocol, storage: Storage) {
        self.api = api
        self.storage = storage
    }

    func fetchProfile(userId: String) async throws -> UserProfile {
        let dto = try await api.fetchProfile(userId: userId)
        return try dto.toDomain()
    }

    func updateProfile(_ profile: UserProfile) async throws {
        // Optimistic update to local storage, then sync to API
        storage.save(object: profile.id, key: "lastViewedProfileId")
        try await api.updateProfile(UserDTO(from: profile))
    }
}
```
