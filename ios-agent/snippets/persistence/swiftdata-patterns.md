# SwiftData Patterns (iOS 17+)

---

## Model definition

```swift
// Features/Feed/Data/FeedItem.swift
import SwiftData

@Model
final class FeedItemRecord {
    var id: String
    var title: String
    var body: String
    var publishedAt: Date
    var isRead: Bool

    init(id: String, title: String, body: String, publishedAt: Date) {
        self.id = id
        self.title = title
        self.body = body
        self.publishedAt = publishedAt
        self.isRead = false
    }
}

// Domain model (pure Swift — never expose @Model to upper layers)
struct FeedItem: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let body: String
    let publishedAt: Date
    var isRead: Bool
}

// Mapping
extension FeedItemRecord {
    func toDomain() -> FeedItem {
        FeedItem(id: id, title: title, body: body, publishedAt: publishedAt, isRead: isRead)
    }
}

extension FeedItem {
    func toRecord() -> FeedItemRecord {
        FeedItemRecord(id: id, title: title, body: body, publishedAt: publishedAt)
    }
}
```

---

## ModelContainer setup

```swift
// App/DI/AppContainer.swift
import SwiftData

lazy var modelContainer: ModelContainer = {
    let schema = Schema([FeedItemRecord.self, UserProfileRecord.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
    return try! ModelContainer(for: schema, configurations: [config])
}()

// In-memory container for tests/previews
static func makeInMemory() -> ModelContainer {
    let schema = Schema([FeedItemRecord.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    return try! ModelContainer(for: schema, configurations: [config])
}
```

---

## Repository with ModelContext

```swift
// Features/Feed/Data/Repositories/FeedRepositoryImpl.swift
import SwiftData

final class FeedRepositoryImpl: FeedRepositoryProtocol {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchFeed() throws -> [FeedItem] {
        let descriptor = FetchDescriptor<FeedItemRecord>(
            sortBy: [SortDescriptor(\.publishedAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor).map { $0.toDomain() }
    }

    func save(_ item: FeedItem) throws {
        let record = item.toRecord()
        modelContext.insert(record)
        try modelContext.save()
    }

    func markAsRead(id: String) throws {
        let predicate = #Predicate<FeedItemRecord> { $0.id == id }
        let descriptor = FetchDescriptor(predicate: predicate)
        guard let record = try modelContext.fetch(descriptor).first else { return }
        record.isRead = true
        try modelContext.save()
    }

    func delete(id: String) throws {
        let predicate = #Predicate<FeedItemRecord> { $0.id == id }
        try modelContext.delete(model: FeedItemRecord.self, where: predicate)
        try modelContext.save()
    }
}
```

---

## Passing ModelContext via DI

```swift
// App/DI/FeedContainer.swift
@MainActor
final class FeedContainer {
    private let modelContext: ModelContext

    init(modelContainer: ModelContainer) {
        self.modelContext = modelContainer.mainContext
    }

    func makeViewModel() -> FeedViewModel {
        FeedViewModel(
            fetchFeedUseCase: FetchFeedUseCase(
                repository: FeedRepositoryImpl(modelContext: modelContext)
            )
        )
    }
}
```

---

## SwiftUI View with @Query (for simple cases)

```swift
// Only use @Query in Views — keep it out of ViewModels
struct FeedView: View {
    @Query(sort: \FeedItemRecord.publishedAt, order: .reverse)
    private var items: [FeedItemRecord]

    var body: some View {
        List(items, id: \.id) { item in
            Text(item.title)
        }
    }
}
```
