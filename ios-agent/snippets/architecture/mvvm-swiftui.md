# MVVM + @Observable — SwiftUI Pattern

Use this template for every new feature ViewModel (iOS 17+).
For iOS 16 target, swap `@Observable` → `@ObservableObject` and `@State` → `@StateObject`.

---

## ViewModel

```swift
// Features/Profile/Presentation/ViewModel/ProfileViewModel.swift
import Observation

@Observable
@MainActor
final class ProfileViewModel {

    // MARK: - Published State (read by Views)

    var profile: UserProfile?
    var isLoading = false
    var errorMessage: String?

    // MARK: - Dependencies (injected via init)

    private let fetchProfileUseCase: FetchProfileUseCaseProtocol

    // MARK: - Init

    init(fetchProfileUseCase: FetchProfileUseCaseProtocol) {
        self.fetchProfileUseCase = fetchProfileUseCase
    }

    // MARK: - Intents (called by View)

    func onAppear(userId: String) async {
        await fetchProfile(userId: userId)
    }

    func retry(userId: String) async {
        await fetchProfile(userId: userId)
    }

    // MARK: - Private

    private func fetchProfile(_ userId: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            profile = try await fetchProfileUseCase.execute(userId: userId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
```

---

## View

```swift
// Features/Profile/Presentation/Views/ProfileView.swift
import SwiftUI

struct ProfileView: View {
    @State private var viewModel: ProfileViewModel
    let userId: String

    // Inject ViewModel (created by DI container or parent)
    init(userId: String, viewModel: ProfileViewModel) {
        self.userId = userId
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        content
            .task { await viewModel.onAppear(userId: userId) }
            .navigationTitle("Profile")
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let profile = viewModel.profile {
            profileContent(profile)
        } else if let error = viewModel.errorMessage {
            ErrorView(message: error)  // KSLibrary UIComponents
                .padding()
        }
    }

    private func profileContent(_ profile: UserProfile) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                Text(profile.name)
                    .font(.title2.bold())
                    .accessibilityAddTraits(.isHeader)
            }
            .padding(Spacing.medium)
        }
    }
}

#Preview {
    ProfileView(
        userId: "preview",
        viewModel: ProfileViewModel(
            fetchProfileUseCase: MockFetchProfileUseCase()
        )
    )
}
```

---

## iOS 16 variant (ObservableObject)

```swift
@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var profile: UserProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?
    // ... same body
}

// In View:
@StateObject private var viewModel: ProfileViewModel
```
