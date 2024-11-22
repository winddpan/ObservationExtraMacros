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
    
    @ObservationUserDefaults(key: "username2")
    @ObservationIgnored
    var name2: String?
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
    
    var testList: [String] = []
}


struct TestView: View {
    @Query(sort: \SwiftDataItem.orderIndex)
    var items: [SwiftDataItem]
    
    var body: some View {
        ForEach(items) { item in
            Text("\(item.orderIndex)")
        }
    }
}
