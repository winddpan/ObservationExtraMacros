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
    func testUsage() {
        let test1 = TestModel()
        test1.name = "hello world"

        let test2 = TestModel()
        XCTAssertEqual(test2.name, "hello world")
        
        test1.name = "hello swift"
        XCTAssertEqual(test2.name, "hello swift")
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
                            _name = ObservationUserDefaultsController<String>(userDefaults: .standard, key: "username", initialValue: initialValue)
                        }
                        get {
                            _name.withinObservation(mutation: { [weak self] in
                                self?.withMutation(keyPath: \.name) {
                                        }
                            })
                            access(keyPath: \.name)
                            return _name.getValue()
                        }
                        set {
                           _name.setValue(newValue)
                        }
                    }

                    @ObservationIgnored
                    private let _name: ObservationUserDefaultsController<String>
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
                            _val = ObservationUserDefaultsController<Int>(userDefaults: .init(suiteName: "Store")!, key: "value", initialValue: initialValue)
                        }
                        get {
                            _val.withinObservation(mutation: { [weak self] in
                                self?.withMutation(keyPath: \.val) {
                                        }
                            })
                            access(keyPath: \.val)
                            return _val.getValue()
                        }
                        set {
                           _val.setValue(newValue)
                        }
                    }

                    @ObservationIgnored
                    private let _val: ObservationUserDefaultsController<Int>
                }
                """#,
            macros: testMacros
        )

    }
}
