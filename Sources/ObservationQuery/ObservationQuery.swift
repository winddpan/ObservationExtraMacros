//
//  ObservationQuery.swift
//  ObservationEx
//
//  Created by winddpan on 2024/11/17.
//

import Foundation
import SwiftData
import SwiftUI

// Available when SwiftUI is imported with SwiftData
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@attached(accessor) @attached(peer, names: prefixed(`_`)) public macro ObservationQuery<Value, Element>(
    filter: Predicate<Element>? = nil, sort keyPath: KeyPath<Element, Value>, order: SortOrder = .forward,
    transaction: Transaction? = nil
) = #externalMacro(module: "ObservationQueryMacros", type: "ObservationQueryMacro")
where Value: Comparable, Element: PersistentModel

// Available when SwiftUI is imported with SwiftData
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@attached(accessor) @attached(peer, names: prefixed(`_`)) public macro ObservationQuery(transaction: Transaction) =
    #externalMacro(module: "ObservationQueryMacros", type: "ObservationQueryMacro")

// Available when SwiftUI is imported with SwiftData
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@attached(accessor) @attached(peer, names: prefixed(`_`)) public macro ObservationQuery(animation: Animation) =
    #externalMacro(module: "ObservationQueryMacros", type: "ObservationQueryMacro")

// Available when SwiftUI is imported with SwiftData
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@attached(accessor) @attached(peer, names: prefixed(`_`)) public macro ObservationQuery<Element>(
    _ descriptor: FetchDescriptor<Element>, animation: Animation
) = #externalMacro(module: "ObservationQueryMacros", type: "ObservationQueryMacro")
where Element: PersistentModel

// Available when SwiftUI is imported with SwiftData
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@attached(accessor) @attached(peer, names: prefixed(`_`)) public macro ObservationQuery<Element>(
    _ descriptor: FetchDescriptor<Element>, transaction: Transaction? = nil
) = #externalMacro(module: "ObservationQueryMacros", type: "ObservationQueryMacro")
where Element: PersistentModel

// Available when SwiftUI is imported with SwiftData
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@attached(accessor) @attached(peer, names: prefixed(`_`)) public macro ObservationQuery<Element>(
    filter: Predicate<Element>? = nil, sort descriptors: [SortDescriptor<Element>] = [], transaction: Transaction? = nil
) = #externalMacro(module: "ObservationQueryMacros", type: "ObservationQueryMacro")
where Element: PersistentModel

// Available when SwiftUI is imported with SwiftData
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@attached(accessor) @attached(peer, names: prefixed(`_`)) public macro ObservationQuery<Value, Element>(
    filter: Predicate<Element>? = nil, sort keyPath: KeyPath<Element, Value?>, order: SortOrder = .forward,
    animation: Animation
) = #externalMacro(module: "ObservationQueryMacros", type: "ObservationQueryMacro")
where Value: Comparable, Element: PersistentModel

// Available when SwiftUI is imported with SwiftData
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@attached(accessor) @attached(peer, names: prefixed(`_`)) public macro ObservationQuery<Value, Element>(
    filter: Predicate<Element>? = nil, sort keyPath: KeyPath<Element, Value>, order: SortOrder = .forward,
    animation: Animation
) = #externalMacro(module: "ObservationQueryMacros", type: "ObservationQueryMacro")
where Value: Comparable, Element: PersistentModel

// Available when SwiftUI is imported with SwiftData
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@attached(accessor) @attached(peer, names: prefixed(`_`)) public macro ObservationQuery<Element>(
    filter: Predicate<Element>? = nil, sort descriptors: [SortDescriptor<Element>] = [], animation: Animation
) = #externalMacro(module: "ObservationQueryMacros", type: "ObservationQueryMacro")
where Element: PersistentModel

// Available when SwiftUI is imported with SwiftData
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@attached(accessor) @attached(peer, names: prefixed(`_`)) public macro ObservationQuery<Value, Element>(
    filter: Predicate<Element>? = nil, sort keyPath: KeyPath<Element, Value?>, order: SortOrder = .forward,
    transaction: Transaction? = nil
) = #externalMacro(module: "ObservationQueryMacros", type: "ObservationQueryMacro")
where Value: Comparable, Element: PersistentModel

// Available when SwiftUI is imported with SwiftData
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@attached(accessor) @attached(peer, names: prefixed(`_`)) public macro ObservationQuery() =
    #externalMacro(module: "ObservationQueryMacros", type: "ObservationQueryMacro")
