import SwiftUI

struct Slip<Answers: View>: View {

    let name: String
    let place: String
    var address: String?
    var priceLevel: Int?
    var seed = 0
    var status: String?
    var isSwiping = false
    @ViewBuilder let answers: Answers

    @State private var scrolled: CGFloat = 0
    @State private var fits = true

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
                if let status {
                    Text(status)
                        .font(.slipStatus)
                        .tracking(1.5)
                        .foregroundStyle(.textMuted)
                } else if let priceLevel {
                    PriceStamp(level: priceLevel, seed: seed)
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
                        Text(AttributedString(handwritten: name, brush: .brush))
                            .ruled(.hand)
                            .foregroundStyle(.handwriting)
                    }
                    Row("Place") {
                        Text(place)
                            .ruled(.answer)
                            .foregroundStyle(.text)
                    }
                    if let address, !address.isEmpty {
                        Row("Address") {
                            Text(address)
                                .ruled(.answer)
                                .foregroundStyle(.text)
                        }
                    }
                    DoubleRule()
                    answers
                }
                .padding(.horizontal, Paper.gutter)
            }
            .scrollDisabled(isSwiping)
            .contentMargins(
                .bottom,
                fits ? 0 : 3 * Paper.line,
                for: .scrollContent
            )
            .onScrollGeometryChange(for: Bool.self) { geometry in
                geometry.contentSize.height <= geometry.containerSize.height
            } action: { _, value in
                fits = value
            }
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

extension Slip where Answers == RestaurantAnswers {

    init(
        restaurant: Restaurant,
        showsAddress: Bool = false,
        isSwiping: Bool = false
    ) {
        self.init(
            name: restaurant.name,
            place: "\(restaurant.category) · \(restaurant.area)",
            address: showsAddress ? restaurant.address : nil,
            priceLevel: restaurant.priceLevel,
            seed: restaurant.seed,
            isSwiping: isSwiping
        ) {
            RestaurantAnswers(restaurant: restaurant)
        }
    }
}

extension Slip where Answers == PlaceholderAnswers {

    init(writing place: Place) {
        self.init(
            name: place.name,
            place: "\(place.category) · \(place.area)",
            address: place.address,
            status: "WRITING…"
        ) {
            PlaceholderAnswers()
        }
    }
}

extension Slip where Answers == EmptyView {

    init(place: Place, status: String? = nil) {
        self.init(
            name: place.name,
            place: "\(place.category) · \(place.area)",
            address: place.address,
            status: status
        ) {
            EmptyView()
        }
    }
}

struct RestaurantAnswers: View {

    let restaurant: Restaurant

    var body: some View {
        ForEach(restaurant.interleavedAnswers, id: \.prompt) { answer in
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
}

struct PlaceholderAnswers: View {

    var body: some View {
        PlaceholderRow(labelWidth: 64, lines: [0.78])
        PlaceholderRow(labelWidth: 52, lines: [0.92, 0.4])
        PlaceholderRow(labelWidth: 70, lines: [0.55])
    }
}

#Preview("Deck") {
    TabView {
        ForEach(Restaurant.samples) { restaurant in
            Slip(restaurant: restaurant)
        }
    }
    .tabViewStyle(.page(indexDisplayMode: .never))
}

#Preview("Writing") {
    Slip(writing: Place.samples[0])
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
                Underline()
            }
        }
    }
}

private struct PlaceholderRow: View {

    let labelWidth: CGFloat
    let lines: [CGFloat]

    var body: some View {
        HStack(alignment: .top, spacing: Paper.columnGap) {
            RoundedRectangle(cornerRadius: 5)
                .fill(.accent.opacity(0.2))
                .frame(width: labelWidth, height: 9)
                .padding(.top, 13)
                .frame(
                    width: Paper.labelWidth,
                    height: Paper.line,
                    alignment: .topLeading
                )
            VStack(spacing: 0) {
                ForEach(lines, id: \.self) { fraction in
                    GeometryReader { geometry in
                        RoundedRectangle(cornerRadius: 6)
                            .fill(.handwriting.opacity(0.16))
                            .frame(
                                width: geometry.size.width * fraction,
                                height: 11
                            )
                            .padding(.top, 12)
                    }
                    .frame(height: Paper.line)
                }
            }
        }
        .background(alignment: .bottom) {
            Underline()
        }
    }
}

private struct Underline: View {

    var body: some View {
        Rectangle()
            .fill(.accent.opacity(0.4))
            .frame(height: 1)
            .padding(.bottom, Paper.line - Paper.rule - 1)
            .padding(.horizontal, -Paper.gutter)
    }
}

private struct PriceStamp: View {

    let level: Int
    let seed: Int

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
            PenCircle(seed: seed)
                .stroke(
                    .handwriting,
                    style: StrokeStyle(lineWidth: 2, lineCap: .round)
                )
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
