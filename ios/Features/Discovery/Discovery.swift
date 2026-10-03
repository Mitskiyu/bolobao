import OpenAPIURLSession
import SwiftUI

struct Discovery: View {

    var load: () async throws -> [Restaurant] = {
        try await Client.shared.restaurants()
    }

    @State private var restaurants: [Restaurant] = []

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(restaurants) { r in
                    Profile(restaurant: r)
                        .padding()
                        .background(
                            .background.secondary,
                            in: .rect(cornerRadius: 16)
                        )
                }
            }
            .padding()
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
