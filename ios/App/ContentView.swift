import SwiftUI

struct ContentView: View {

    var discovery = Discovery()

    @State private var tab: TabBar.Tab = .deck
    @State private var isAdding = false
    @AppStorage("hasSeenWelcome") private var hasSeenWelcome = false
    @State private var showsWelcome = !UserDefaults.standard.bool(
        forKey: "hasSeenWelcome"
    )

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                TopBar()
                    .zIndex(1)
                ZStack {
                    discovery
                    if tab == .saved {
                        Saved()
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
            if showsWelcome {
                Welcome {
                    hasSeenWelcome = true
                    withAnimation(.easeIn(duration: 0.35).delay(0.12)) {
                        showsWelcome = false
                    }
                }
                .transition(.move(edge: .top))
                .zIndex(2)
            }
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
    .environment(SavedStore(folder: nil))
    .environment(SeenStore(folder: nil))
}
