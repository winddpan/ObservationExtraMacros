import CoreData
import Foundation
import SwiftData
import SwiftUI

extension ModelContext {
    fileprivate static let _swiftDataModelsChangedInContext = NSNotification.Name(
        rawValue: "_SwiftDataModelsChangedInContextNotificationPrivate")
    static let swiftDataModelsChangedInContext = NSNotification.Name(
        rawValue: "swiftDataModelsChangedInContextNotification")
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@MainActor @preconcurrency public class ObservationQueryController<Element: PersistentModel> {
    private var descriptor = FetchDescriptor<Element>()

    private var transaction: Transaction?
    private var animation: Animation?
    private var shouldUpdateAfterDidChange = false

    private var onMutation: ((() -> Void) -> Void)?
    private weak var modelContext: ModelContext?

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(contextModelsChanged),
            name: ModelContext._swiftDataModelsChangedInContext,
            object: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(swiftDataModelsChanged),
            name: ModelContext.swiftDataModelsChangedInContext,
            object: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(persistentStoreCoordinatorDidChang),
            name: .NSPersistentStoreCoordinatorStoresDidChange,
            object: nil)
    }

    @objc private func persistentStoreCoordinatorDidChang(_ notification: Notification) {
        immediateUpdate()
    }

    @objc private func swiftDataModelsChanged(_ notification: Notification) {
        if let object = notification.object as? String, object == String(describing: Element.self) {
            immediateUpdate()
        }
    }

    @objc private func contextModelsChanged(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let modelContext = notification.object as? ModelContext else { return }
        self.modelContext = modelContext

        let array = [
            modelContext.insertedModelsArray + modelContext.deletedModelsArray + modelContext.changedModelsArray
        ].flatMap({ $0 })
        if array.contains(where: { $0 is Element }) {
            immediateUpdate()
        }
    }

    public func withinObservation(mutation: @escaping ((() -> Void) -> Void)) {
        self.onMutation = mutation
    }

    public func immediateUpdate() {
        if let transaction {
            withTransaction(transaction) {
                onMutation?({ [weak self] in
                    self?._results = nil
                })
            }
        } else if let animation {
            withAnimation(animation) {
                onMutation?({ [weak self] in
                    self?._results = nil
                })
            }
        } else {
            onMutation?({ [weak self] in
                self?._results = nil
            })
        }
    }

    private(set) var _results: [Element]?
    public var results: [Element] {
        if _results == nil, let modelContext = modelContext ?? ObservationQuery.modelContext {
            _results = try? modelContext.fetch(descriptor)
        }
        return _results ?? []
    }
}

extension ObservationQueryController {
    /// Creates a query with a predicate, a key path to a property for sorting,
    /// and the order to sort by.
    ///
    /// Use `Query` within a view by wrapping the variable for the query's
    /// result:
    ///
    ///         @ObservationQuery(sort: \.dateCreated)
    ///         var favoriteRecipes: [Recipe]
    ///
    /// - Parameters:
    ///   - filter: A predicate on `Element`
    ///   - sort: Key path to property used for sorting.
    ///   - order: Whether to sort in forward or reverse order.
    ///   - animation: The animation to use for user interface changes that
    ///                result from changes to the fetched results.
    @MainActor @preconcurrency public convenience init<Value>(
        filter: Predicate<Element>? = nil, sort keyPath: KeyPath<Element, Value>, order: SortOrder = .forward,
        animation: Animation
    ) where Value: Comparable {
        self.init()
        self.descriptor.predicate = filter
        self.descriptor.sortBy = [SortDescriptor.init(keyPath, order: order)]
        self.animation = animation
    }

    /// Creates a query with a predicate, a key path to a property for sorting,
    /// and the order to sort by.
    ///
    /// Use `Query` within a view by wrapping the variable for the query's
    /// result:
    ///
    ///         @ObservationQuery(sort: \.dateCreated)
    ///         var favoriteRecipes: [Recipe]
    ///
    /// - Parameters:
    ///   - filter: A predicate on `Element`
    ///   - sort: Key path to property used for sorting.
    ///   - order: Whether to sort in forward or reverse order.
    ///   - animation: The animation to use for user interface changes that
    ///                result from changes to the fetched results.
    @MainActor @preconcurrency public convenience init<Value>(
        filter: Predicate<Element>? = nil, sort keyPath: KeyPath<Element, Value?>, order: SortOrder = .forward,
        animation: Animation
    ) where Value: Comparable {
        self.init()
        self.descriptor.predicate = filter
        self.descriptor.sortBy = [SortDescriptor.init(keyPath, order: order)]
        self.animation = animation
    }

    /// Creates a query with a predicate, a key path to a property for sorting,
    /// and the order to sort by.
    ///
    /// Use `Query` within a view by wrapping the variable for the query's
    /// result:
    ///
    ///         @ObservationQuery(sort: \.dateCreated)
    ///         var favoriteRecipes: [Recipe]
    ///
    /// - Parameters:
    ///   - filter: A predicate on `Element`
    ///   - sort: Key path to property used for sorting.
    ///   - order: Whether to sort in forward or reverse order.
    ///   - transaction: A transaction to use for user interface changes that
    ///                  result from changes to the fetched results.
    @MainActor @preconcurrency public convenience init<Value>(
        filter: Predicate<Element>? = nil, sort keyPath: KeyPath<Element, Value>, order: SortOrder = .forward,
        transaction: Transaction? = nil
    ) where Value: Comparable {
        self.init()
        self.descriptor.predicate = filter
        self.descriptor.sortBy = [SortDescriptor.init(keyPath, order: order)]
        self.transaction = transaction
    }

    /// Creates a query with a predicate, a key path to a property for sorting,
    /// and the order to sort by.
    ///
    /// Use `Query` within a view by wrapping the variable for the query's
    /// result:
    ///
    ///         @ObservationQuery(sort: \.dateCreated)
    ///         var favoriteRecipes: [Recipe]
    ///
    /// - Parameters:
    ///   - filter: A predicate on `Element`
    ///   - sort: Key path to property used for sorting.
    ///   - order: Whether to sort in forward or reverse order.
    ///   - transaction: A transaction to use for user interface changes that
    ///                  result from changes to the fetched results.
    @MainActor @preconcurrency public convenience init<Value>(
        filter: Predicate<Element>? = nil, sort keyPath: KeyPath<Element, Value?>, order: SortOrder = .forward,
        transaction: Transaction? = nil
    ) where Value: Comparable {
        self.init()
        self.descriptor.predicate = filter
        self.descriptor.sortBy = [SortDescriptor.init(keyPath, order: order)]
        self.transaction = transaction
    }

    /// Creates a query with a predicate, a key path to a property for sorting,
    /// and the order to sort by.
    ///
    /// Use `Query` within a view by wrapping the variable for the query's
    /// result:
    ///
    ///         @ObservationQuery(
    ///             filter: #Predicate { $0.isFavorite == true },
    ///             sort: [SortDescriptor(\.dateCreated)]
    ///         )
    ///         var favoriteRecipes: [Recipe]
    ///
    /// - Parameters:
    ///   - filter: A predicate on `Element`
    ///   - descriptors: Sort orders for the result.
    ///   - animation: The animation to use for user interface changes that
    ///                result from changes to the fetched results.
    @MainActor @preconcurrency public convenience init(
        filter: Predicate<Element>? = nil, sort descriptors: [SortDescriptor<Element>] = [], animation: Animation
    ) {
        self.init()
        self.descriptor.predicate = filter
        self.descriptor.sortBy = descriptors
        self.transaction = transaction
    }

    /// Create a query with a predicate, and a list of sort descriptors.
    ///
    /// Use `Query` within a view by wrapping the variable for the query's
    /// result:
    ///
    ///         @ObservationQuery(
    ///             filter: #Predicate { $0.isFavorite == true },
    ///             sort: [SortDescriptor(\.dateCreated)]
    ///         )
    ///         var favoriteRecipes: [Recipe]
    ///
    /// - Parameters:
    ///   - filter: A predicate on `Element`
    ///   - descriptors: Sort orders for the result.
    ///   - transaction: A transaction to use for user interface changes that
    ///                  result from changes to the fetched results.
    @MainActor @preconcurrency public convenience init(
        filter: Predicate<Element>? = nil, sort descriptors: [SortDescriptor<Element>] = [],
        transaction: Transaction? = nil
    ) {
        self.init()
        self.descriptor.predicate = filter
        self.descriptor.sortBy = descriptors
        self.transaction = transaction
    }

    /// Create a query with a SwiftData fetch descriptor.
    ///
    /// - Parameters:
    ///   - descriptor: a `SwiftData.FetchDescriptor`.
    ///   - transaction: A transaction to use for user interface changes that
    ///                  result from changes to the fetched results.
    @MainActor @preconcurrency public convenience init(
        _ descriptor: FetchDescriptor<Element>, transaction: Transaction? = nil
    ) {
        self.init()
        self.descriptor = descriptor
        self.transaction = transaction
    }

    /// Create a query with a SwiftData fetch descriptor.
    ///
    /// - Parameters:
    ///   - descriptor: a `SwiftData.FetchDescriptor`.
    ///   - animation: The animation to use for user interface changes that
    ///                result from changes to the fetched results.
    @MainActor @preconcurrency public convenience init(_ descriptor: FetchDescriptor<Element>, animation: Animation) {
        self.init()
        self.descriptor = descriptor
        self.animation = animation
    }

}
