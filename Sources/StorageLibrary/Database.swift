import Combine
import CoreData
import Foundation
import LoggerLibrary
import Observation
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
/// ### Accessing iCloud database status
/// - ``status``
///
/// ### Querying Data
/// - ``fetch(_:predicate:sortBy:)``
/// - ``count(_:)``
/// - ``isEmpty(_:)``
///
/// ### Managing Data
/// - ``flush()``
@MainActor
@Observable
public class Database {

    // MARK: - Definitions -

    /// The ecent that iCloud generated after syncing
    /// Could be either `imported` (from iCloud) or `exported` (to iCloud)
    /// `none` means that there is nothing to sync.
    public enum DatabaseEvent: Equatable {
        case imported
        case exported
        case none
    }

    /// The current status of iCloud sync
    /// When all records are synced, a done event will be fired with the proper `event` type
    /// Preferable, don't update records while status is syncing.
    public enum DatabaseStatus: Equatable {
        case idle
        case checking
        case syncing
        case done(event: DatabaseEvent)
        case error(String)
    }

    // MARK: - Properties -

    private let models: [any PersistentModel.Type]
    private let inMemory: Bool
    private let logger = Logger(category: "com.cassiorossi.database")

    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Public Observable Properties -

    /// Current status of iCloud syncing
    public var status: DatabaseStatus = .idle

    // MARK: - Main Model Container -

    /// The shared model container for persisting data.
    ///
    /// This lazy property creates and configures a `ModelContainer` based on the models and storage type provided during initialization.
    ///
    /// - Important: This will cause a fatal error if the container cannot be created.
    @ObservationIgnored
    public lazy var sharedModelContainer: ModelContainer = {
        do {
            let schema = Schema(models)

            // Configure ModelConfiguration with CloudKit sync enabled
            let modelConfiguration: ModelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: inMemory
            )

            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])

            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    /// The main actor-isolated model context for performing database operations.
    ///
    /// This lazy property provides a `ModelContext` with undo support enabled and autosave configured.
    ///
    /// - Important: Must be accessed from the main actor.
    @MainActor
    @ObservationIgnored
    public lazy var context: ModelContext = {
        let context = ModelContext(sharedModelContainer)
        context.undoManager = UndoManager()
        context.autosaveEnabled = true
        return context
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

        if !inMemory {
            observeCloudKitChanges()
            logger.debug("initial database status: \(status)")
        }
    }

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

private extension Database {
    func observeCloudKitChanges() {
        NotificationCenter.default.publisher(for: .NSManagedObjectContextObjectsDidChange)
            .receive(on: RunLoop.main)
            .sink { [weak self] notification in
                guard let self else { return }

                var objects = [NSManagedObject]()
                objects.append(contentsOf: Array(notification.userInfo?[NSInsertedObjectsKey] as? Set<NSManagedObject> ?? []).map { $0 })
                objects.append(contentsOf: Array(notification.userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject> ?? []).map { $0 })
                objects.append(contentsOf: Array(notification.userInfo?[NSDeletedObjectsKey] as? Set<NSManagedObject> ?? []).map { $0 })
                objects.append(contentsOf: Array(notification.userInfo?[NSRefreshedObjectsKey] as? Set<NSManagedObject> ?? []).map { $0 })

                objects = objects.filter { $0.isPersistentModel(based: self.models) }
                if !objects.isEmpty {
                    let status = self.status
                    self.status = .checking
                    self.logger.debug("database status: from \(status) to \(self.status)")
                }
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: NSPersistentCloudKitContainer.eventChangedNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] notification in
                guard let self,
                      let event = notification.userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey] as? NSPersistentCloudKitContainer.Event else {
                    return
                }

                if self.status == .checking {
                    let status = self.status
                    if let error = event.error {
                        self.status = .error(error.localizedDescription)
                    }

                    if event.startDate != nil && !event.succeeded {
                        self.status = .syncing
                    }

                    if event.endDate != nil && event.succeeded {
                        switch event.type {
                        case .export: self.status = .done(event: .exported)
                        case .import: self.status = .done(event: .imported)
                        default: break
                        }
                    }
                    self.logger.debug("database status: from \(status) to \(self.status)")
                }
            }
            .store(in: &cancellables)
    }
}

// MARK: - CoreData Extensions -

private extension NSManagedObject {
    func isPersistentModel(based models: [any PersistentModel.Type]) -> Bool {
        guard let entityName = entity.name else { return false }
        return models.contains { modelType in
            String(describing: modelType) == entityName ||
            String(reflecting: modelType).contains(".\(entityName)")
        }
    }
}
