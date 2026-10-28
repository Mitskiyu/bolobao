import Foundation
import Observation

@MainActor
@Observable
final class SavedStore {

    private(set) var restaurants: [Restaurant] = []

    private let url = URL.applicationSupportDirectory
        .appending(path: "saved.json")

    init() {
        load()
    }

    func contains(_ restaurant: Restaurant) -> Bool {
        restaurants.contains { $0.id == restaurant.id }
    }

    func save(_ restaurant: Restaurant) {
        guard !contains(restaurant) else { return }
        restaurants.insert(restaurant, at: 0)
        write()
    }

    func remove(_ restaurant: Restaurant) {
        restaurants.removeAll { $0.id == restaurant.id }
        write()
    }

    private func load() {
        guard let data = try? Data(contentsOf: url) else { return }
        restaurants =
            (try? JSONDecoder().decode([Restaurant].self, from: data)) ?? []
    }

    private func write() {
        try? FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try? JSONEncoder().encode(restaurants).write(to: url, options: .atomic)
    }
}
