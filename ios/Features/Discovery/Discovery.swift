import OpenAPIURLSession
import SwiftUI

struct Discovery: View {

    @State private var restaurants: [Restaurant] = []
    @State private var cursor: String? = nil
    @State private var isLoading: Bool = false
    @State private var isDone: Bool = false
    @State private var dragX: CGFloat = 0
    @State private var axis: Axis?
    @State private var isFlying = false
    @State private var tapped: Bool?
    @State private var dragSave = false
    @State private var tapOpacity: CGFloat = 0
    @State private var tapScale: CGFloat = 1.5

    @Environment(SavedStore.self) private var saved
    @Environment(SeenStore.self) private var seen

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
            while restaurants.count < 5 {
                let page = try await fetch(cursor, nil)
                if page.isEmpty {
                    isDone = true
                    return
                }

                cursor = page.last?.id
                restaurants.append(
                    contentsOf: page.filter {
                        !seen.contains($0) && !saved.contains($0)
                    }
                )
            }
        } catch {
            print(error)
        }
    }

    private func skip() {
        guard let first = restaurants.first else { return }
        seen.insert(first)
        restaurants.removeFirst()

        refill()
    }

    private func save() {
        guard let first = restaurants.first else {
            return
        }
        seen.insert(first)
        saved.save(first)
        restaurants.removeFirst()

        refill()
    }

    private func refill() {
        if restaurants.count < 5 {
            Task { await load() }
        }
    }

    private var stampSave: Bool {
        tapped ?? dragSave
    }

    private var stampOpacity: CGFloat {
        guard tapped == nil else { return tapOpacity }
        return min(max((abs(dragX) - 20) / 90, 0), 1)
    }

    private var stampScale: CGFloat {
        tapped == nil ? 1.5 - 0.5 * stampOpacity : tapScale
    }

    private func tap(save: Bool) {
        guard !isFlying, !restaurants.isEmpty else { return }
        isFlying = true
        tapped = save
        FrameRate.shared.boost()
        withAnimation(.easeOut(duration: 0.16)) {
            tapOpacity = 1
        }
        withAnimation(.timingCurve(0.3, 1.6, 0.5, 1, duration: 0.26)) {
            tapScale = 1
        }
        Task {
            try? await Task.sleep(for: .milliseconds(380))
            flyOff(save: save)
        }
    }

    private func flyOff(
        save: Bool,
        animation: Animation = .timingCurve(
            0.45, 0.05, 0.55, 0.95, duration: 0.65)
    ) {
        isFlying = true
        FrameRate.shared.boost()
        withAnimation(animation) {
            dragX = save ? 640 : -640
        } completion: {
            save ? self.save() : skip()
            dragX = 0
            tapped = nil
            tapOpacity = 0
            tapScale = 1.5
            isFlying = false
            FrameRate.shared.reset()
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
                    if axis == .horizontal {
                        FrameRate.shared.boost()
                    }
                }
                if axis == .horizontal {
                    dragX = value.translation.width
                    if dragX != 0 {
                        dragSave = dragX > 0
                    }
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
                    } completion: {
                        FrameRate.shared.reset()
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
                Slip(
                    restaurant: restaurant,
                    isSwiping: isTop && axis == .horizontal
                )
                .overlay {
                    SlipStamp(
                        save: stampSave,
                        opacity: isTop ? stampOpacity : 0,
                        scale: stampScale
                    )
                }
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
                    tap(save: false)
                } label: {
                    Stamp(text: "SKIP", color: .textMuted, seed: 1)
                        .rotationEffect(.degrees(-5))
                }
                Spacer()
                Button {
                    tap(save: true)
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
        .environment(SavedStore(folder: nil))
        .environment(SeenStore(folder: nil))
}

private struct SlipStamp: View {

    let save: Bool
    let opacity: CGFloat
    let scale: CGFloat

    var body: some View {
        Stamp(
            text: save ? "SAVED" : "SKIPPED",
            color: save ? .accent : .textMuted,
            size: 48,
            seed: save ? 3 : 4
        )
        .rotationEffect(.degrees(save ? -12 : 10))
        .scaleEffect(scale)
        .opacity(0.9 * opacity)
        .padding(.top, 104)
        .padding(save ? .leading : .trailing, save ? 40 : 34)
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: save ? .topLeading : .topTrailing
        )
        .allowsHitTesting(false)
    }
}
