import SwiftUI

struct Stamp: View {

    let text: String
    let color: Color
    var size: CGFloat = 30
    var seed = 0

    var body: some View {
        Text(AttributedString(handwritten: text, brush: .brush))
            .font(.hand(size))
            .foregroundStyle(color)
            .padding(.horizontal, size * 0.5)
            .padding(.vertical, size * 0.15)
            .overlay {
                PenCircle(seed: seed)
                    .stroke(
                        color,
                        style: StrokeStyle(
                            lineWidth: max(2, size / 14),
                            lineCap: .round
                        )
                    )
            }
    }
}

#Preview {
    ZStack {
        Color.surface.ignoresSafeArea()
        Paper()
        Stamp(text: "SAVED", color: .accent, size: 64)
            .rotationEffect(.degrees(-12))
        VStack {
            Spacer()
            HStack {
                Stamp(text: "SKIP", color: .textMuted, seed: 1)
                    .rotationEffect(.degrees(-5))
                Spacer()
                Stamp(text: "SAVE", color: .accent, seed: 2)
                    .rotationEffect(.degrees(4))
            }
            .padding(.horizontal, Paper.gutter)
            .padding(.bottom, 24)
        }
    }
}
