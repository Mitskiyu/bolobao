import SwiftUI

struct Writing: View {

    enum Outcome {
        case writing, refused, failed, limited, unreachable
        case done(Restaurant)
    }

    let place: Place
    var close: () -> Void = {}
    var write:
        (_ id: String) async throws -> any AsyncSequence<
            ProfileEvent, any Error
        > = { id in
            try await Client.writer.createProfile(id: id)
        }

    @State var phase: Phase? = nil
    @State var outcome: Outcome = .writing
    @State private var attempt = 0

    @Environment(SavedStore.self) private var saved
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(spacing: 0) {
            SheetHeader(button: "Search", isBack: true) {
                dismiss()
            }
            switch outcome {
            case .writing:
                Slip(writing: place)
                Steps(phase: phase)
            case .done(let restaurant):
                Slip(restaurant: restaurant, showsAddress: true)
                DoneBar(isSaved: saved.contains(restaurant)) {
                    if saved.contains(restaurant) {
                        saved.remove(restaurant)
                    } else {
                        saved.save(restaurant)
                    }
                } openMaps: {
                    openURL(restaurant.mapsURL)
                }
            case .refused:
                Slip(place: place)
                    .overlay(alignment: .topTrailing) { VoidStamp() }
                Notice(
                    title: "Couldn't find enough about this place",
                    text:
                        "We only write a slip when there's enough to trust. Check you picked the right address, or try another shop."
                ) {
                    InkButton(
                        title: "CLOSE",
                        color: .textMuted,
                        isFilled: false,
                        tilt: 1,
                        action: close
                    )
                    .frame(width: 148)
                    InkButton(title: "TRY ANOTHER", tilt: -1) { dismiss() }
                }
            case .failed:
                Slip(place: place)
                    .overlay(alignment: .topTrailing) { VoidStamp() }
                Notice(
                    title: "Something broke on our side",
                    text:
                        "We stopped partway through writing this slip. That's our fault, not the shop's. Give it another go in a moment."
                ) {
                    InkButton(
                        title: "CLOSE",
                        color: .textMuted,
                        isFilled: false,
                        tilt: 1,
                        action: close
                    )
                    .frame(width: 148)
                    InkButton(title: "TRY AGAIN", tilt: -1, action: retry)
                }
            case .limited:
                Slip(place: place, status: "NOT STARTED")
                Notice(
                    title: "Daily limit reached",
                    text:
                        "We write up to 30 new slips a day, and today's are used up. Try again tomorrow, or pick a place that's already ticked."
                ) {
                    InkButton(
                        title: "BACK",
                        color: .text,
                        isFilled: false,
                        tilt: -1
                    ) { dismiss() }
                }
            case .unreachable:
                Slip(place: place, status: "NOT STARTED")
                Notice(
                    title: "Can't reach Bolobao right now",
                    text:
                        "Check your connection and try again. If it keeps happening, our side may be down for a bit."
                ) {
                    InkButton(
                        title: "BACK",
                        color: .text,
                        isFilled: false,
                        tilt: 1
                    ) { dismiss() }
                    .frame(width: 148)
                    InkButton(title: "TRY AGAIN", tilt: -1, action: retry)
                }
            }
        }
        .background(.surface)
        .toolbar(.hidden, for: .navigationBar)
        .task(id: attempt) {
            do {
                let events = try await write(place.id)
                for try await event in events {
                    phase = event.phase
                    switch event.phase {
                    case .done:
                        outcome = event.profile.map(Outcome.done) ?? .failed
                    case .refused:
                        outcome = .refused
                    case .failed:
                        outcome = .failed
                    default:
                        break
                    }
                }
                if case .writing = outcome, !Task.isCancelled {
                    outcome = .failed
                }
            } catch ErrorCode.rateLimited {
                outcome = .limited
            } catch {
                guard !Task.isCancelled else { return }
                outcome = phase == nil ? .unreachable : .failed
            }
        }
    }

    private func retry() {
        phase = nil
        outcome = .writing
        attempt += 1
    }
}

#Preview("Reading") {
    Writing(place: Place.samples[0], write: idle)
}

#Preview("Writing") {
    Writing(place: Place.samples[0], write: idle, phase: .read)
}

#Preview("Checking") {
    Writing(place: Place.samples[0], write: idle, phase: .wrote)
}

#Preview("Done") {
    Writing(
        place: Place.samples[0],
        write: idle,
        outcome: .done(Restaurant.sample)
    )
    .environment(SavedStore())
}

#Preview("Refused") {
    Writing(place: Place.samples[0], write: idle, outcome: .refused)
}

#Preview("Failed") {
    Writing(place: Place.samples[0], write: idle, outcome: .failed)
}

#Preview("Limited") {
    Writing(place: Place.samples[0], write: idle, outcome: .limited)
}

#Preview("Unreachable") {
    Writing(place: Place.samples[0], write: idle, outcome: .unreachable)
}

private let idle:
    (String) async throws -> any AsyncSequence<ProfileEvent, any Error> = {
        _ in
        AsyncThrowingStream<ProfileEvent, any Error> { _ in }
    }

extension Restaurant {

    fileprivate var mapsURL: URL {
        var components = URLComponents(string: "https://maps.apple.com/")!
        components.queryItems = [
            URLQueryItem(name: "q", value: name),
            URLQueryItem(name: "ll", value: "\(lat),\(lon)"),
        ]
        return components.url!
    }
}

private struct VoidStamp: View {

    var body: some View {
        Stamp(text: "Void", color: .accent, size: 46, seed: 5)
            .rotationEffect(.degrees(-9))
            .padding(.top, 340)
            .padding(.trailing, 34)
            .allowsHitTesting(false)
    }
}
