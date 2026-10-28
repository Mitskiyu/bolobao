import Foundation
import Observation

@MainActor
@Observable
final class SeenStore {

    private(set) var ids: Set<String> = []

    private let url: URL?

    init(folder: URL? = .applicationSupportDirectory) {
        url = folder?.appending(path: "seen.json")
        load()
    }

    func contains(_ restaurant: Restaurant) -> Bool {
        ids.contains(restaurant.id)
    }

    func insert(_ restaurant: Restaurant) {
        guard ids.insert(restaurant.id).inserted else { return }
        write()
    }

    private func load() {
        guard let url, let data = try? Data(contentsOf: url) else { return }
        ids = (try? JSONDecoder().decode(Set<String>.self, from: data)) ?? []
    }

    private func write() {
        guard let url else { return }
        try? FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try? JSONEncoder().encode(ids).write(to: url, options: .atomic)
    }
}
