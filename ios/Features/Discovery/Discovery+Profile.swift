import SwiftUI

extension Discovery {

    struct Profile: View {

        let restaurant: Restaurant

        @State private var scrolled: CGFloat = 0

        var body: some View {
            VStack(spacing: 0) {
                HStack {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text("ORDER").tracking(3)
                        Text("落單").tracking(2)
                    }
                    .font(.printedHeader)
                    .foregroundStyle(.accent)
                    Spacer()
                    if let level = restaurant.priceLevel {
                        PriceStamp(level: level)
                    }
                }
                .padding(.horizontal, Paper.gutter)
                .frame(height: 56)

                RoundedRectangle(cornerRadius: 3)
                    .fill(.surfaceMuted)
                    .frame(height: 210)
                    .overlay {
                        Text("Photo")
                            .font(.small)
                            .foregroundStyle(.textMuted)
                    }
                    .padding(.horizontal, Paper.gutter)

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Row("Name") {
                            Text(
                                AttributedString(
                                    handwritten: restaurant.name,
                                    brush: .brush
                                )
                            )
                            .ruled(.hand)
                            .foregroundStyle(.handwriting)
                        }
                        Row("Place") {
                            Text("\(restaurant.category) · \(restaurant.area)")
                                .ruled(.answer)
                                .foregroundStyle(.text)
                        }
                        DoubleRule()
                        ForEach(restaurant.interleavedAnswers, id: \.prompt) {
                            answer in
                            Row(answer.prompt.title, underlined: true) {
                                if answer.prompt.isDish {
                                    Text(
                                        AttributedString(
                                            handwritten: answer.text,
                                            brush: .brushSmall
                                        )
                                    )
                                    .ruled(.handSmall)
                                    .foregroundStyle(.handwriting)
                                } else {
                                    Text(answer.text)
                                        .ruled(.answer)
                                        .foregroundStyle(.text)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, Paper.gutter)
                }
                .contentMargins(.bottom, 3 * Paper.line, for: .scrollContent)
                .onScrollGeometryChange(for: CGFloat.self) { geometry in
                    geometry.contentOffset.y + geometry.contentInsets.top
                } action: { _, offset in
                    scrolled = offset
                }
                .background(Paper(scrolled: scrolled))
                .padding(.top, 12)
            }
            .background(.surface)
        }
    }
}

private struct Row<Content: View>: View {

    let label: String
    let underlined: Bool
    let content: Content

    init(
        _ label: String,
        underlined: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.label = label
        self.underlined = underlined
        self.content = content()
    }

    var body: some View {
        RuledRow {
            HStack(alignment: .top, spacing: Paper.columnGap) {
                Text(label.uppercased())
                    .tracking(0.8)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .ruled(.label)
                    .foregroundStyle(.accent)
                    .frame(width: Paper.labelWidth, alignment: .leading)
                content
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .background(alignment: .bottom) {
            if underlined {
                Rectangle()
                    .fill(.accent.opacity(0.4))
                    .frame(height: 1)
                    .padding(.bottom, Paper.line - Paper.rule - 1)
                    .padding(.horizontal, -Paper.gutter)
            }
        }
    }
}

private struct PriceStamp: View {

    let level: Int

    var body: some View {
        Text(
            AttributedString(
                handwritten: String(repeating: "$", count: level),
                brush: .brush
            )
        )
        .font(Font(UIFont.hand))
        .foregroundStyle(.handwriting)
        .padding(.horizontal, 6)
        .frame(minWidth: 40, minHeight: 40)
        .overlay {
            Ellipse().stroke(.handwriting, lineWidth: 2)
        }
        .rotationEffect(.degrees(-8))
    }
}

private struct DoubleRule: View {

    var body: some View {
        Color.clear
            .frame(height: Paper.line)
            .overlay(alignment: .top) {
                VStack(spacing: 2) {
                    Rectangle().frame(height: 1)
                    Rectangle().frame(height: 1)
                }
                .foregroundStyle(.accent)
                .padding(.top, Paper.rule - 3)
            }
            .padding(.horizontal, -Paper.gutter)
    }
}

#Preview {
    TabView {
        ForEach(Restaurant.samples) { restaurant in
            Discovery.Profile(restaurant: restaurant)
        }
    }
    .tabViewStyle(.page(indexDisplayMode: .never))
}
