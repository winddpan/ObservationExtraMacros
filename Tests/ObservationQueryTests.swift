import ObservationQuery
import ObservationQueryMacros
import SwiftData
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import SwiftUI
import XCTest

private let testMacros: [String: Macro.Type] = [
    "ObservationQuery": ObservationQueryMacro.self
]

final class ObservationQueryTests: XCTestCase {
    func testStandardMacro() throws {
        assertMacroExpansion(
            """
            @Observable
            class TestModel {
                @ObservationQuery
                @ObservationIgnored
                var items: [Item]
            }
            """,
            expandedSource: #"""
                @Observable
                class TestModel {
                    @ObservationIgnored
                    var items: [Item] {
                        get {
                            _items.onMutation = { [weak self] mutation in
                                self?.withMutation(keyPath: \.items) {
                                    mutation()
                                }
                            }
                            access(keyPath: \.items)
                            return _items.results
                        }
                    }

                    @ObservationIgnored
                    private let _items = ObservationQueryController<Item>()
                }
                """#,
            macros: testMacros
        )
    }

    func testSortMacro() throws {
        assertMacroExpansion(
            """
            @Observable
            class TestModel {
                @ObservationQuery(sort: \\Item.orderIndex)
                @ObservationIgnored
                var items: [Item]
            }
            """,
            expandedSource: #"""
                @Observable
                class TestModel {
                    @ObservationIgnored
                    var items: [Item] {
                        get {
                            _items.onMutation = { [weak self] mutation in
                                self?.withMutation(keyPath: \.items) {
                                    mutation()
                                }
                            }
                            access(keyPath: \.items)
                            return _items.results
                        }
                    }

                    @ObservationIgnored
                    private let _items = ObservationQueryController<Item>(sort: \Item.orderIndex)
                }
                """#,
            macros: testMacros
        )

    }
}
