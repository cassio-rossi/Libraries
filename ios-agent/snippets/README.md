# Snippet Library Index

**Read this file before writing any Swift code.**
If a pattern exists here, use it — do not reimplement.

---

## Architecture

| Snippet | File | Use Case |
|---|---|---|
| MVVM + @Observable ViewModel | `architecture/mvvm-swiftui.md` | Any new feature ViewModel |
| Clean Architecture layers | `architecture/clean-arch-layers.md` | Feature folder structure |
| Coordinator Navigation | `architecture/coordinator-nav.md` | NavigationStack-based routing |
| Dependency Injection container | `architecture/dependency-injection.md` | App-level DI root |

## Networking (KSLibrary NetworkLibrary)

| Snippet | File | Use Case |
|---|---|---|
| KSLibrary Network full usage | `networking/ks-network-usage.md` | All HTTP calls — CustomHost, Endpoint, DefaultNetwork, NetworkMock |
| Async/await patterns | `networking/async-await-patterns.md` | Structured concurrency, task groups, cancellation |

## Persistence (KSLibrary StorageLibrary)

| Snippet | File | Use Case |
|---|---|---|
| SwiftData patterns | `persistence/swiftdata-patterns.md` | iOS 17+ persistence with @Model |
| KSLibrary Keychain & UserDefaults | `persistence/ks-storage-keychain.md` | SecureStorage (Keychain), DefaultStorage (UserDefaults) |
| CoreData patterns | `persistence/coredata-patterns.md` | iOS 16 and below |

## UI (KSLibrary UIComponentsLibrary)

| Snippet | File | Use Case |
|---|---|---|
| KSLibrary UI Components | `ui/ks-ui-components.md` | All UIComponentsLibrary components with SwiftUI usage |
| SwiftUI Navigation | `ui/swiftui-navigation.md` | NavigationStack, sheets, full-screen covers |
| Design System setup | `ui/design-system.md` | Color/typography/spacing tokens |
| Accessibility | `ui/accessibility.md` | VoiceOver labels, Dynamic Type, tap targets |

## Testing

| Snippet | File | Use Case |
|---|---|---|
| ViewModel unit tests | `testing/xctest-viewmodel.md` | XCTest with mock repositories |
| XCUITest flows | `testing/xcuitest-flows.md` | Critical user journey UI tests |

## SOLID / DRY Patterns

| Snippet | File | Use Case |
|---|---|---|
| Protocol-oriented design | `solid-dry/protocol-oriented.md` | Protocol + default impl + dependency inversion |
| Generic reuse | `solid-dry/generic-reuse.md` | Generic types, constrained extensions |
