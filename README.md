# ObservationUserDefaults
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

#  ObservationQuery
```swift
import ObservationQuery
import SwiftData
import SwiftUI

@main
struct MainApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
        .observationQueryModelContext(sharedModelContainer.mainContext)
    }
}

let sharedModelContainer: ModelContainer = {
    let schema = Schema([
        Item.self
    ])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false, allowsSave: true)

    do {
        return try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
        fatalError("Could not create ModelContainer: \(error)")
    }
}()
```

```swift

import Observation
import ObservationQuery
import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = TheViewModel()

    var items: [Item] {
        viewModel.items
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    Text(
                        item.timestamp,
                        format: Date.FormatStyle(
                            date: .numeric, time: .standard))
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
            .navigationTitle("\(items.count)")
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

@Model
final class Item {
    var timestamp: Date

    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}

@Observable
class TheViewModel {
    @ObservationQuery(sort: \Item.timestamp)
    @ObservationIgnored
    var items: [Item]
}
```
