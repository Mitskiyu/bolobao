import SwiftUI

@main
struct bolobaoApp: App {

    @State private var saved = SavedStore()
    @State private var seen = SeenStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(saved)
                .environment(seen)
        }
    }
}
