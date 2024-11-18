import ObservationUserDefaults
import ObservationUserDefaultsMacros
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

@Observable
private class TestModel {
    @ObservationUserDefaults(key: "username")
    @ObservationIgnored
    var name: String = ""
}

private let testMacros: [String: Macro.Type] = [
    "ObservationUserDefaults": ObservationUserDefaultsMacro.self
]

final class ObservationUserDefaultsTests: XCTestCase {

    func testUserDefaults() {
        struct Item: Codable {
            let name: String
        }

        let item = Item(name: "name")
        UserDefaults.standard._$observationSet(item, forKey: "item")
        let get = UserDefaults.standard._$observationGet(
            Item.self, forKey: "item")
        XCTAssertEqual(item.name, get?.name)

        UserDefaults.standard._$observationSet("haha", forKey: "wa")
        UserDefaults.standard.string(forKey: "wa")
        XCTAssertEqual("haha", UserDefaults.standard.string(forKey: "wa"))
    }

    func testUsage() {
        let test1 = TestModel()
        test1.name = "hello world"

        let test2 = TestModel()
        XCTAssertEqual(test2.name, "hello world")
    }

    func testObservationUserDefaultsStandardStoreMacro() throws {
        assertMacroExpansion(
            """
            @Observable
            class Model {
                @ObservationUserDefaults(key: "username")
                @ObservationIgnored
                var name: String = "User"
            }
            """,
            expandedSource: #"""
                @Observable
                class Model {
                    @ObservationIgnored
                    var name: String = "User" {
                        @storageRestrictions(initializes: _name)
                        init(initialValue) {
                            _name = initialValue
                        }
                        get {
                            access(keyPath: \.name)
                            let store: UserDefaults = .standard
                            return store._$observationGet(String.self, forKey: "username") ?? _name
                        }
                        set {
                            withMutation(keyPath: \.name) {
                                let store: UserDefaults = .standard
                                store._$observationSet(newValue, forKey: "username")
                            }
                        }
                    }

                    @ObservationIgnored private let _name: String
                }
                """#,
            macros: testMacros
        )

    }

    func testObservationUserDefaultsCustomStoreMacro() throws {
        assertMacroExpansion(
            """
            @Observable
            class Model {
                @ObservationUserDefaults(key: "value", store: .init(suiteName: "Store")!)
                @ObservationIgnored
                var val: Int = 1
            }
            """,
            expandedSource: #"""
                @Observable
                class Model {
                    @ObservationIgnored
                    var val: Int = 1 {
                        @storageRestrictions(initializes: _val)
                        init(initialValue) {
                            _val = initialValue
                        }
                        get {
                            access(keyPath: \.val)
                            let store: UserDefaults = .init(suiteName: "Store")!
                            return store._$observationGet(Int.self, forKey: "value") ?? _val
                        }
                        set {
                            withMutation(keyPath: \.val) {
                                let store: UserDefaults = .init(suiteName: "Store")!
                                store._$observationSet(newValue, forKey: "value")
                            }
                        }
                    }

                    @ObservationIgnored private let _val: Int
                }
                """#,
            macros: testMacros
        )

    }
}
