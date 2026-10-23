import OpenAPIURLSession
import SwiftUI

struct Discovery: View {

    @State private var restaurants: [Restaurant] = []
    @State private var saved: [Restaurant] = []
    @State private var cursor: String? = nil
    @State private var isLoading: Bool = false
    @State private var isDone: Bool = false
    @State private var dragX: CGFloat = 0
    @State private var axis: Axis?
    @State private var isFlying = false

    var fetch: (_ cursor: String?, _ limit: Int?) async throws -> [Restaurant] =
        {
            cursor,
            limit in
            try await Client.shared.restaurants(cursor: cursor, limit: limit)
        }

    private func load() async {
        if isLoading || isDone { return }

        isLoading = true
        defer { isLoading = false }

        do {
            let page = try await fetch(cursor, nil)
            if page.isEmpty {
                isDone = true
                return
            }

            restaurants.append(contentsOf: page)
            cursor = page.last?.id
        } catch {
            print(error)
        }
    }

    private func skip() {
        guard !restaurants.isEmpty else { return }
        restaurants.removeFirst()

        refill()
    }

    private func save() {
        guard let first = restaurants.first else {
            return
        }
        saved.append(first)
        restaurants.removeFirst()

        refill()
    }

    private func refill() {
        if restaurants.count < 5 {
            Task { await load() }
        }
    }

    private func flyOff(
        save: Bool,
        animation: Animation = .timingCurve(
            0.45, 0.05, 0.55, 0.95, duration: 0.65)
    ) {
        isFlying = true
        withAnimation(animation) {
            dragX = save ? 640 : -640
        } completion: {
            save ? self.save() : skip()
            dragX = 0
            isFlying = false
        }
    }

    private var drag: some Gesture {
        DragGesture(minimumDistance: 10)
            .onChanged { value in
                guard !isFlying else { return }
                if axis == nil {
                    let width = abs(value.translation.width)
                    let height = abs(value.translation.height)
                    axis = width > height ? .horizontal : .vertical
                }
                if axis == .horizontal {
                    dragX = value.translation.width
                }
            }
            .onEnded { value in
                defer { axis = nil }
                guard axis == .horizontal, !isFlying else { return }
                let x = value.predictedEndTranslation.width
                if abs(x) > 110 {
                    let speed = max(abs(value.velocity.width), 1)
                    let distance = 640 - abs(dragX)
                    let duration = min(max(distance / speed, 0.15), 0.4)
                    flyOff(save: x > 0, animation: .easeOut(duration: duration))
                } else {
                    withAnimation(
                        .timingCurve(0.2, 0.8, 0.2, 1, duration: 0.42)
                    ) {
                        dragX = 0
                    }
                }
            }
    }

    var body: some View {
        ZStack {
            Color.canvas.ignoresSafeArea()
            ForEach(restaurants.prefix(2).reversed()) { restaurant in
                let isTop = restaurant.id == restaurants.first?.id
                let x = isTop ? dragX : 0
                Profile(
                    restaurant: restaurant,
                    isSwiping: isTop && axis == .horizontal
                )
                .background {
                    Rectangle()
                        .fill(.surface)
                        .shadow(
                            color: .black.opacity(x == 0 ? 0 : 0.22),
                            radius: 14,
                            y: 10
                        )
                }
                .rotationEffect(
                    .degrees(min(max(x / 18, -16), 16)),
                    anchor: .bottom
                )
                .offset(x: x, y: 0.05 * abs(x))
                .allowsHitTesting(isTop)
            }
        }
        .simultaneousGesture(drag)
        .overlay(alignment: .bottom) {
            HStack {
                Button {
                    flyOff(save: false)
                } label: {
                    Stamp(text: "SKIP", color: .textMuted, seed: 1)
                        .rotationEffect(.degrees(-5))
                }
                Spacer()
                Button {
                    flyOff(save: true)
                } label: {
                    Stamp(text: "SAVE", color: .accent, seed: 2)
                        .rotationEffect(.degrees(4))
                }
            }
            .buttonStyle(.plain)
            .padding(.horizontal, Paper.gutter)
            .padding(.top, 40)
            .padding(.bottom, 8)
            .background {
                LinearGradient(
                    colors: [.surface.opacity(0), .surface.opacity(0.94)],
                    startPoint: .top,
                    endPoint: UnitPoint(x: 0.5, y: 0.6)
                )
                .ignoresSafeArea(edges: .bottom)
            }
        }
        .task {
            await load()
        }
    }
}

#Preview {
    Discovery(fetch: { cursor, _ in cursor == nil ? Restaurant.samples : [] })
}
