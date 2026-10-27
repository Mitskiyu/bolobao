import SwiftUI

struct ContentView: View {

    var discovery = Discovery()

    @State private var tab: TabBar.Tab = .deck
    @State private var isAdding = false

    var body: some View {
        VStack(spacing: 0) {
            TopBar()
                .zIndex(1)
            ZStack {
                discovery
                if tab == .saved {
                    Color.surface
                }
            }
            TabBar(selected: isAdding ? .add : tab) { selected in
                if selected == .add {
                    isAdding = true
                } else {
                    tab = selected
                }
            }
        }
        .background(alignment: .top) {
            Color.topBar.ignoresSafeArea()
        }
        .sheet(isPresented: $isAdding) {
            AddPlace()
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
