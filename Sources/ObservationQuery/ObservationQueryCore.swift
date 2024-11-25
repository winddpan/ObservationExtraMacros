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
