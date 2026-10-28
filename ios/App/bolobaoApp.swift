import SwiftUI

@main
struct bolobaoApp: App {

    @State private var saved = SavedStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(saved)
        }
    }
}
