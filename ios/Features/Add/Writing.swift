import SwiftUI

struct Writing: View {

    let place: Place
    @State var phase: Phase? = nil

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            SheetHeader(button: "Search", isBack: true) {
                dismiss()
            }
            Slip(place: place, status: "WRITING…")
            Steps(phase: phase)
        }
        .background(.surface)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            do {
                let events = try await Client.writer.createProfile(
                    id: place.id
                )
                for try await event in events {
                    phase = event.phase
                }
            } catch {
                print(error)
            }
        }
    }
}

#Preview("Reading") {
    Writing(place: Place.samples[0])
}

#Preview("Writing") {
    Writing(place: Place.samples[0], phase: .read)
}

#Preview("Checking") {
    Writing(place: Place.samples[0], phase: .wrote)
}

private struct Steps: View {

    let phase: Phase?

    private var current: Int {
        switch phase {
        case nil: 0
        case .read: 1
        case .wrote: 2
        default: 3
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Writing the slip…")
                .font(.hand(28))
                .foregroundStyle(.handwriting)
            VStack(alignment: .leading, spacing: 12) {
                Step(
                    title: "Read what people wrote about it",
                    index: 0,
                    current: current
                )
                Step(title: "Writing the slip", index: 1, current: current)
                Step(
                    title: "Checking every line against the sources",
                    index: 2,
                    current: current
                )
            }
            Text("Usually takes about a minute.")
                .font(.rowDetail)
                .foregroundStyle(.textMuted)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, Paper.gutter)
        .padding(.top, 18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            Color.surface
                .shadow(color: .black.opacity(0.05), radius: 8, y: -6)
                .ignoresSafeArea(edges: .bottom)
        }
        .overlay(alignment: .top) {
            Rectangle()
                .fill(.surfaceMuted)
                .frame(height: 1)
        }
    }
}

private struct Step: View {

    let title: String
    let index: Int
    let current: Int

    var body: some View {
        HStack(spacing: 12) {
            Group {
                if index < current {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.handwriting)
                } else if index == current {
                    Image(systemName: "smallcircle.filled.circle")
                        .foregroundStyle(.accent)
                } else {
                    Image(systemName: "circle")
                        .foregroundStyle(.textMuted)
                }
            }
            .font(.system(size: 20))
            .frame(width: 22, height: 22)
            Text(title)
                .font(index == current ? .stepCurrent : .step)
                .foregroundStyle(index > current ? .textMuted : .text)
        }
    }
}
