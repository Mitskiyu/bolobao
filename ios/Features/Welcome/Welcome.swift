import SwiftUI

struct Welcome: View {

    let start: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("ORDER").tracking(3)
                Text("落單").tracking(2)
                Spacer()
            }
            .ruled(.printedHeader)
            .foregroundStyle(.accent)
            .padding(.horizontal, Paper.gutter)
            .padding(.top, Paper.line)

            VStack(spacing: 0) {
                Image(.bolobaoTransparent)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 5 * Paper.line)
                    .offset(y: -6)
                Text("Bolobao")
                    .tracking(1)
                    .ruled(.welcome)
                    .foregroundStyle(.accent)
                    .padding(.top, Paper.line)
                Text(
                    AttributedString(
                        handwritten: "Where should we eat?",
                        brush: .brush,
                        overhang: 10
                    )
                )
                .ruled(.handLarge)
                .foregroundStyle(.handwriting)
                .rotationEffect(.degrees(-2))
                .padding(.top, Paper.line)
                Text(
                    "Swipe on Hong Kong restaurant slips, based on what people actually wrote about each place."
                )
                .ruled(.answer)
                .foregroundStyle(.text)
                .frame(maxWidth: 330)
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 32)
            .padding(.top, 3 * Paper.line)

            Spacer(minLength: 0)

            InkButton(title: "GET STARTED", action: start)
                .padding(.horizontal, Paper.gutter)
                .padding(.bottom, 24)
        }
        .background {
            GeometryReader { geometry in
                Paper(
                    scrolled: -geometry.safeAreaInsets.top
                        .truncatingRemainder(dividingBy: Paper.line),
                    showsMargin: false
                )
                .ignoresSafeArea()
            }
        }
        .background(.surface)
    }
}

#Preview {
    Welcome {}
}
