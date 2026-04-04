# XCTest — ViewModel Unit Tests

---

## Full ViewModel test template

```swift
// Tests/Features/Profile/ProfileViewModelTests.swift
import XCTest
@testable import MyApp

@MainActor
final class ProfileViewModelTests: XCTestCase {

    // MARK: - SUT

    private var sut: ProfileViewModel!
    private var mockUseCase: MockFetchProfileUseCase!

    // MARK: - Setup / Teardown

    override func setUp() {
        super.setUp()
        mockUseCase = MockFetchProfileUseCase()
        sut = ProfileViewModel(fetchProfileUseCase: mockUseCase)
    }

    override func tearDown() {
        sut = nil
        mockUseCase = nil
        super.tearDown()
    }

    // MARK: - onAppear

    func test_onAppear_success_setsProfile() async throws {
        // Arrange
        let expected = UserProfile(id: "1", name: "Alice", bio: nil, avatarURL: nil, createdAt: .now)
        mockUseCase.stubbedProfile = expected

        // Act
        await sut.onAppear(userId: "1")

        // Assert
        XCTAssertEqual(sut.profile, expected)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }

    func test_onAppear_failure_setsErrorMessage() async {
        // Arrange
        mockUseCase.shouldThrow = true

        // Act
        await sut.onAppear(userId: "1")

        // Assert
        XCTAssertNil(sut.profile)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNotNil(sut.errorMessage)
    }

    func test_onAppear_setsIsLoadingDuringFetch() async {
        // Arrange
        var loadingDuringFetch = false
        mockUseCase.onExecute = {
            loadingDuringFetch = self.sut.isLoading
        }

        // Act
        await sut.onAppear(userId: "1")

        // Assert — was loading during fetch
        XCTAssertTrue(loadingDuringFetch)
        XCTAssertFalse(sut.isLoading)  // false after completion
    }
}
```

---

## Mock UseCase template

```swift
// Tests/Mocks/MockFetchProfileUseCase.swift
final class MockFetchProfileUseCase: FetchProfileUseCaseProtocol {

    // MARK: - Stubs

    var stubbedProfile: UserProfile?
    var shouldThrow = false
    var onExecute: (() -> Void)?

    // MARK: - Spy

    private(set) var executeCallCount = 0
    private(set) var lastExecutedUserId: String?

    // MARK: - Protocol

    func execute(userId: String) async throws -> UserProfile {
        executeCallCount += 1
        lastExecutedUserId = userId
        onExecute?()

        if shouldThrow { throw AppError.notFound }
        return stubbedProfile ?? UserProfile(id: userId, name: "Mock", bio: nil, avatarURL: nil, createdAt: .now)
    }
}
```

---

## Testing with NetworkMock (integration)

```swift
// Uses KSLibrary NetworkMock — no real network calls
import NetworkLibrary

final class UserRepositoryImplTests: XCTestCase {

    func test_fetchUser_success_returnsMappedDomain() async throws {
        // Arrange
        let mockData = [NetworkMockData(api: "/v1/users/42", filename: "user_42")]
        let network = NetworkFactory.make(mapper: mockData)
        let sut = UserRepositoryImpl(api: UserAPI(network: network))

        // Act
        let result = try await sut.fetchUser(id: "42")

        // Assert
        XCTAssertEqual(result.id, "42")
        XCTAssertFalse(result.name.isEmpty)
    }
}
```

Place `user_42.json` in `Tests/Resources/` and add it to the test target's bundle.
