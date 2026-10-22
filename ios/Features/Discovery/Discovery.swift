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
