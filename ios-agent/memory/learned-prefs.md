# Learned Preferences

Style and convention preferences discovered over working sessions.
Updated automatically by the agent; also editable by the user.

---

## Code Style

- **SwiftUI only** — no UIKit unless bridging a third-party component.
- **`@Observable`** (iOS 17+) over `ObservableObject`. When targeting iOS 16, use `@ObservableObject`.
- **`async/await`** everywhere — no completion handlers, no Combine for async work.
- **`final class`** for ViewModels and service classes — not designed for subclassing.
- **`@MainActor`** on all ViewModel classes.
- Explicit `public`/`internal`/`private` on every declaration.
- Trailing closure syntax when the last (or only) argument is a closure.
- Prefer `guard let` over nested `if let`.

## Architecture

- Feature-slice layout: `Features/<Name>/Domain|Data|Presentation`.
- DI via `init` only — no service locators, no singletons except the DI container root.
- One file per type. Max ~200 lines per file before splitting.

## Naming

- ViewModels: `<Feature>ViewModel` (e.g., `ProfileViewModel`).
- UseCases: `<Verb><Noun>UseCase` (e.g., `FetchProfileUseCase`).
- Repositories: `<Noun>Repository` protocol, `<Noun>RepositoryImpl` concrete.
- DTOs: `<Noun>DTO` (e.g., `UserDTO`).
- Errors: `<Domain>Error` enum (e.g., `ProfileError`).

## Testing

- Mocks are named `Mock<Protocol>` (e.g., `MockProfileRepository`).
- Arrange/Act/Assert comments in every test method.
- Test method: `test_<method>_<scenario>_<expectation>()`.

## UI

- Design tokens in `DesignSystem/Tokens/` — always use them, never hardcode.
- `SF Symbols` for icons unless brand requires custom assets.
- Corner radius standard: 12pt for cards, 8pt for buttons.
- Primary action button: full-width, `.buttonStyle(.borderedProminent)`.

## KSLibrary Preferences

- Always use `CachedAsyncImage(image:)` for remote images (Kingfisher-backed).
- Use `ErrorView(message:)` for inline validation errors — it already animates.
- Use `CircularProgressView(progress:lineWidth:color:)` for progress rings.
- Always inject `Logger(category: "<FeatureName>")` into classes that do I/O.
