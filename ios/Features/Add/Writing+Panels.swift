import SwiftUI

extension Writing {

    struct Steps: View {

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
            Panel {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Working on it…")
                        .font(.hand(28))
                        .foregroundStyle(.handwriting)
                    VStack(alignment: .leading, spacing: 12) {
                        Step(
                            title: "Read what people wrote about it",
                            index: 0,
                            current: current
                        )
                        Step(
                            title: "Writing the slip",
                            index: 1,
                            current: current
                        )
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
            }
        }
    }

    struct Notice<Buttons: View>: View {

        let title: String
        let text: String
        @ViewBuilder let buttons: Buttons

        var body: some View {
            Panel(top: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(title)
                        .font(.messageTitle)
                    Text(text)
                        .font(.message)
                    HStack(spacing: 14) {
                        buttons
                    }
                    .padding(.top, 6)
                }
                .foregroundStyle(.text)
            }
        }
    }

    struct DoneBar: View {

        @Binding var isSaved: Bool
        let openMaps: () -> Void

        var body: some View {
            Panel(top: 14) {
                HStack(spacing: 14) {
                    InkButton(
                        title: isSaved ? "SAVED" : "SAVE",
                        icon: isSaved ? Image(systemName: "checkmark") : nil,
                        isFilled: false,
                        tilt: 1.5
                    ) {
                        isSaved.toggle()
                    }
                    .frame(width: 150)
                    InkButton(
                        title: "OPEN IN MAPS",
                        icon: Image(.mapPin),
                        color: .handwriting,
                        action: openMaps
                    )
                }
            }
        }
    }
}

private struct Panel<Content: View>: View {

    var top: CGFloat = 18
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(.horizontal, Paper.gutter)
            .padding(.top, top)
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
