import OpenAPIURLSession
import SwiftUI

struct Discovery: View {

    var load: () async throws -> [Restaurant] = {
        try await Client.shared.restaurants()
    }

    @State private var restaurants: [Restaurant] = []

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
                } label: {
                    Stamp(text: "SKIP", color: .textMuted, seed: 1)
                        .rotationEffect(.degrees(-5))
                }
                Spacer()
                Button {
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
            do {
                restaurants = try await load()
            } catch {
                print(error)
            }
        }
    }
}

#Preview {
    Discovery(load: { Restaurant.samples })
}
