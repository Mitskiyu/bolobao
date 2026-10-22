import SwiftUI

struct ContentView: View {

    var discovery = Discovery()

    var body: some View {
        VStack(spacing: 0) {
            TopBar()
            discovery
        }
        .background(alignment: .top) {
            Color.topBar.ignoresSafeArea()
        }
    }
}

#Preview {
    ContentView(discovery: Discovery(load: { Restaurant.samples }))
}
