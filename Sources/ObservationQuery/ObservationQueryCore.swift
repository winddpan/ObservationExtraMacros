//
//  ObservationQueryCore.swift
//  ObservationExtraMacros
//
//  Created by winddpan on 2024/11/19.
//

import SwiftData
import SwiftUI

// Relate ModelContext in @ObservationQuery
public struct ObservationQuery {
    @MainActor public static var modelContext: ModelContext?
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension View {
    @MainActor @preconcurrency public func observationQueryModelContext(_ modelContext: ModelContext) -> Self {
        ObservationQuery.modelContext = modelContext
        return self
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension Scene {
    @MainActor @preconcurrency public func observationQueryModelContext(_ modelContext: ModelContext) -> Self {
        ObservationQuery.modelContext = modelContext
        return self
    }
}

extension ModelContext {
    ///   Replaces the system's delete method and notifies @ObservationQuery to refresh.
    /// - Parameters:
    ///   - model: The type of the model to delete.
    ///   - predicate: An optional predicate to filter the models to be deleted.
    ///   - includeSubclasses: A boolean indicating whether to include subclasses in the deletion.
    public func deleteWithinObservation<T>(
        model: T.Type, where predicate: Predicate<T>? = nil, includeSubclasses: Bool = true
    ) throws where T: PersistentModel {
        try self.delete(model: model, where: predicate, includeSubclasses: includeSubclasses)
        NotificationCenter.default
            .post(name: ModelContext.swiftDataModelsChangedInContext, object: String.init(describing: model))
    }

}
