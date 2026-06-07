import SwiftData
import SwiftUI

@main
struct LocalPinsApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            PhotoPin.self,
            PinBoard.self,
        ])

        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Unable to create model container: \(error.localizedDescription)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
