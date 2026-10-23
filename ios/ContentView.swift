import SwiftUI

struct ContentView: View {

    var discovery = Discovery()

    var body: some View {
        VStack(spacing: 0) {
            TopBar()
                .zIndex(1)
            discovery
        }
        .background(alignment: .top) {
            Color.topBar.ignoresSafeArea()
        }
    }
}

#Preview {
    ContentView(
        discovery: Discovery(fetch: { cursor, _ in
            cursor == nil ? Restaurant.samples : []
        })
    )
}
