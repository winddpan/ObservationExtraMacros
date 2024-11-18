import Foundation
import Observation
import ObservationQuery
import ObservationUserDefaults
import SwiftData
import SwiftUI

@Observable
class UserDefaultsModel {
    @ObservationUserDefaults(key: "username")
    @ObservationIgnored
    var name: String = ""
}

@Model
final class SwiftDataItem {
    var orderIndex: Int
    init(orderIndex: Int) {
        self.orderIndex = orderIndex
    }
}

@Observable
class QueryModel {
    @ObservationQuery(sort: \SwiftDataItem.orderIndex)
    @ObservationIgnored
    var items: [SwiftDataItem]
}
