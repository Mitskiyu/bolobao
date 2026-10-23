import OpenAPIURLSession
import SwiftUI

struct Discovery: View {

    @State private var restaurants: [Restaurant] = []
    @State private var saved: [Restaurant] = []
    @State private var cursor: String? = nil
    @State private var isLoading: Bool = false
    @State private var isDone: Bool = false

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

    var body: some View {
        ZStack {
            Color.canvas.ignoresSafeArea()
            if let restaurant = restaurants.first {
                Profile(restaurant: restaurant)
            }
        }
        .overlay(alignment: .bottom) {
            HStack {
                Button {
                    skip()
                } label: {
                    Stamp(text: "SKIP", color: .textMuted, seed: 1)
                        .rotationEffect(.degrees(-5))
                }
                Spacer()
                Button {
                    save()
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
