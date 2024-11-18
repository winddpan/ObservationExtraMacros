```swift
import Observation
import ObservationUserDefaults

@Observable
class UserDefaultsModel {
    @ObservationUserDefaults(key: "username")
    @ObservationIgnored
    var name: String = ""
}
```

```swift
import Observation
import ObservationQuery
import SwiftData

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
```
