//
//  ObservationUserDefaultsController.swift
//  ObservationExtraMacros
//
//  Created by winddpan on 2024/11/22.
//
import Foundation

public class ObservationUserDefaultsController<T>: NSObject {
    public let userDefaults: UserDefaults
    public let key: String
    public var initialValue: T
    private var onMutation: (() -> Void)?

    public func withinObservation(mutation: @escaping (() -> Void)) {
        self.onMutation = mutation
    }

    deinit {
        self.userDefaults.removeObserver(self, forKeyPath: key)
    }

    public init(userDefaults: UserDefaults, key: String, initialValue: T) {
        self.userDefaults = userDefaults
        self.key = key
        self.initialValue = initialValue
        super.init()
        userDefaults.addObserver(self, forKeyPath: key, options: .new, context: nil)

    }

    public override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == self.key {
            onMutation?()
        }
    }
}

extension ObservationUserDefaultsController {
    public func getValue() -> T {
        if let value = value(forKey: key) as? T {
            return value
        }
        return initialValue
    }

    public func getValue() -> T where T: Codable {
        var result: T?
        if [Int.self, Float.self, Double.self, Bool.self, URL.self, String.self, Data.self, [String].self].contains(where: { T.self == $0 })
        {
            result = userDefaults.value(forKey: key) as? T
        }
        if let data = userDefaults.value(forKey: key) as? Data {
            result = try? JSONDecoder().decode(T.self, from: data)
        }
        if let result = result {
            return result
        }
        return initialValue
    }

    public func setValue(_ value: T?) {
        userDefaults.set(value, forKey: key)
    }

    public func setValue(_ value: T?) where T: Codable {
        guard let value else {
            userDefaults.set(nil, forKey: key)
            return
        }
        if [Int.self, Float.self, Double.self, Bool.self, URL.self, String.self, Data.self, [String].self].contains(where: { T.self == $0 })
        {
            userDefaults.set(value, forKey: key)
        } else {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .sortedKeys
            let data = try? encoder.encode(value)
            userDefaults.set(data, forKey: key)
        }
    }
}
