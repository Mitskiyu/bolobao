import SwiftUI

struct TabBar: View {

    enum Tab {
        case deck, add, saved
    }

    let selected: Tab
    let select: (Tab) -> Void

    var body: some View {
        HStack(spacing: 0) {
            Item(
                title: "Deck",
                icon: "rectangle.portrait.on.rectangle.portrait",
                isSelected: selected == .deck
            ) { select(.deck) }
            Item(
                title: "Add a place",
                icon: "plus.circle",
                isSelected: selected == .add
            ) { select(.add) }
            Item(
                title: "Saved",
                icon: "bookmark",
                isSelected: selected == .saved
            ) { select(.saved) }
        }
        .offset(y: -6)
        .ignoresSafeArea(edges: .bottom)
        .frame(height: 49)
        .background {
            Color.topBar.ignoresSafeArea(edges: .bottom)
        }
        .overlay(alignment: .top) {
            Rectangle()
                .fill(.surfaceMuted)
                .frame(height: 1)
        }
    }
}

#Preview {
    VStack {
        Spacer()
        TabBar(selected: .deck) { _ in }
    }
    .background(.canvas)
}

private struct Item: View {

    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .frame(height: 24)
                Text(title)
                    .font(isSelected ? .tabSelected : .tab)
            }
            .foregroundStyle(isSelected ? .accent : .textMuted)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(.rect)
            .animation(nil, value: isSelected)
        }
        .buttonStyle(.plain)
    }
}
