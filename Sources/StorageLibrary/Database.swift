import Combine
import CoreData
import Foundation
import SwiftData

/// A wrapper for managing SwiftData model containers and contexts.
///
/// Provides a simplified interface for working with SwiftData, including support for in-memory storage, fetching, counting, and flushing data.
///
/// ```swift
/// let database = Database(models: [User.self, Post.self], inMemory: false)
/// let users = await database.fetch(User.self, predicate: #Predicate { $0.isActive })
/// ```
///
/// ## Topics
///
/// ### Creating a Database Instance
/// - ``init(models:inMemory:)``
///
/// ### Accessing the Model Container
/// - ``sharedModelContainer``
/// - ``context``
///
/// ### Querying Data
/// - ``fetch(_:predicate:sortBy:)``
/// - ``count(_:)``
/// - ``isEmpty(_:)``
///
/// ### Managing Data
/// - ``flush()``
@MainActor
public class Database {

    // MARK: - Properties -

    private let models: [any PersistentModel.Type]
    private let inMemory: Bool
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Main Model Container -

    /// The shared model container for persisting data.
    ///
    /// This lazy property creates and configures a `ModelContainer` based on the models and storage type provided during initialization.
    ///
    /// - Important: This will cause a fatal error if the container cannot be created.
    public lazy var sharedModelContainer: ModelContainer = {
        do {
            let schema = Schema(models)
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: inMemory
            )
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    // MARK: - Init methods -

    /// Creates a database instance.
    ///
    /// - Parameters:
    ///   - models: Array of `PersistentModel` types to be managed by the database.
    ///   - inMemory: Whether the database should be stored in memory only (defaults to `false`).
    ///
    /// - Note: When `inMemory` is `true`, data will not persist between app launches.
    public init(models: [any PersistentModel.Type],
                inMemory: Bool = false) {
        self.models = models
        self.inMemory = inMemory

        // Set up remote change notification observer for iCloud sync
        if !inMemory {
            setupRemoteChangeObserver()
        }
    }

    /// The main actor-isolated model context for performing database operations.
    ///
    /// This lazy property provides a `ModelContext` with undo support enabled and autosave configured.
    ///
    /// - Important: Must be accessed from the main actor.
    @MainActor
    public lazy var context: ModelContext = {
        let context = ModelContext(sharedModelContainer)
        context.undoManager = UndoManager()
        context.autosaveEnabled = true
        return context
    }()

    /// Checks if the database contains any objects of the specified type.
    ///
    /// - Parameter type: The `PersistentModel` type to check.
    ///
    /// - Returns: `true` if no objects exist, `false` otherwise.
    ///
    /// - Important: Must be called from the main actor.
    @MainActor
    public func isEmpty<T>(_ type: T.Type) -> Bool where T: PersistentModel {
        return count(type) == 0
    }

    /// Returns the number of objects of the specified type in the database.
    ///
    /// - Parameter type: The `PersistentModel` type to count.
    ///
    /// - Returns: The count of objects, or `0` if an error occurs.
    ///
    /// - Important: Must be called from the main actor.
    @MainActor
    public func count<T>(_ type: T.Type) -> Int where T: PersistentModel {
        let fetchDescriptor = FetchDescriptor<T>()
        return (try? context.fetchCount(fetchDescriptor)) ?? 0
    }

    /// Fetches objects from the database with optional filtering and sorting.
    ///
    /// - Parameters:
    ///   - type: The `PersistentModel` type to fetch.
    ///   - predicate: Optional predicate for filtering results.
    ///   - sortBy: Array of sort descriptors for ordering results (defaults to empty).
    ///
    /// - Returns: Array of fetched objects, or empty array if an error occurs.
    ///
    /// - Important: Must be called from the main actor.
    @MainActor
    public func fetch<T>(_ type: T.Type,
                         predicate: Predicate<T>? = nil,
                         sortBy: [SortDescriptor<T>] = []) -> [T] where T: PersistentModel {
        let descriptor = FetchDescriptor(predicate: predicate, sortBy: sortBy)
        return (try? context.fetch(descriptor)) ?? []
    }

    // MARK: - Remote Change Handling -

    /// Sets up observer for remote CloudKit changes to ensure UI updates across devices.
    private func setupRemoteChangeObserver() {
        // Listen for remote store changes from CloudKit
        NotificationCenter.default.publisher(for: .NSPersistentStoreRemoteChange)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                if self?.context.hasChanges ?? false {
                    try? self?.context.save()
                }
            }
            .store(in: &cancellables)
    }
}

extension Database {
    /// Deletes all objects from the database for all registered model types.
    ///
    /// - Important: Must be called from the main actor. This operation cannot be undone.
    ///
    /// - Note: Changes are saved to the context after deletion.
    @MainActor
    public func flush() {
        let ctx = context
        for modelType in models {
            _deleteAll(of: modelType, in: ctx)
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
