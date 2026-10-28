import SwiftUI

@main
struct bolobaoApp: App {

    @State private var saved = SavedStore()
    @State private var seen = SeenStore()

    init() {
        URLCache.shared = URLCache(
            memoryCapacity: 50_000_000,
            diskCapacity: 200_000_000
        )
        UIScrollView.appearance().indicatorStyle = .black
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(saved)
                .environment(seen)
        }
    }
}
