import Foundation
import SwiftData

public class Database {

    // MARK: - Properties -

    private let models: [PersistentModel.Type]
    private let inMemory: Bool

    // MARK: - Main Model Container -

    public lazy var sharedModelContainer: ModelContainer = {
        do {
            let schema = Schema(models)
            let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    // MARK: - Init methods -

    public init(models: [PersistentModel.Type],
                inMemory: Bool = false) {
        self.models = models
        self.inMemory = inMemory
    }

    @MainActor
    public lazy var context: ModelContext = {
        let context = ModelContext(sharedModelContainer)
        context.undoManager = UndoManager()
        return context
    }()

    @MainActor
    public func isEmpty<T>(_ type: T.Type) -> Bool where T: PersistentModel {
        return count(type) == 0
    }

    @MainActor
    public func count<T>(_ type: T.Type) -> Int where T: PersistentModel {
        let fetchDescriptor = FetchDescriptor<T>()
        return (try? context.fetchCount(fetchDescriptor)) ?? 0
    }

    @MainActor
    public func fetch<T>(_ type: T.Type,
                         predicate: Predicate<T>? = nil,
                         sortBy: [SortDescriptor<T>] = []) -> [T] where T: PersistentModel {
        let descriptor = FetchDescriptor(predicate: predicate, sortBy: sortBy)
        return (try? context.fetch(descriptor)) ?? []
    }
}

extension Database {
    @MainActor
    public func flush() {
        let ctx = context
        for modelType in models {
            if let typedType = modelType as? any PersistentModel.Type {
                _deleteAll(of: typedType, in: ctx)
            }
        }
    }

    @MainActor
    private func _deleteAll<T: PersistentModel>(of type: T.Type, in ctx: ModelContext) {
        let descriptor = FetchDescriptor<T>()
        if let items = try? ctx.fetch(descriptor) {
            for item in items {
                ctx.delete(item)
            }
            try? ctx.save()
        }
    }
}
