import Foundation

@attached(accessor, names: named(init), named(get), named(set))
@attached(peer, names: prefixed(`_`))
public macro ObservationUserDefaults(key: String, store: Foundation.UserDefaults = .standard) = #externalMacro(
    module: "ObservationUserDefaultsMacros",
    type: "ObservationUserDefaultsMacro"
)

