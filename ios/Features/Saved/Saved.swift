import SwiftUI

struct Saved: View {

    @State private var selected: Restaurant?

    @Environment(SavedStore.self) private var saved

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Header(count: saved.restaurants.count)
                if saved.restaurants.isEmpty {
                    Empty()
                } else {
                    VStack(spacing: 0) {
                        ForEach(saved.restaurants) { restaurant in
                            Button {
                                selected = restaurant
                            } label: {
                                Row(
                                    restaurant: restaurant,
                                    isLast: restaurant.id
                                        == saved.restaurants.last?.id
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(.horizontal, Paper.gutter)
            .padding(.bottom, 20)
        }
        .background(.surface)
        .sheet(item: $selected) { restaurant in
            SavedSlip(restaurant: restaurant)
        }
    }
}

#Preview {
    let saved = SavedStore(folder: nil)
    Restaurant.samples.reversed().forEach(saved.save)
    return Saved()
        .environment(saved)
}

#Preview("Empty") {
    Saved()
        .environment(SavedStore(folder: nil))
}

private struct Header: View {

    let count: Int

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text("SAVED")
                .font(.printedHeader)
                .tracking(3)
                .foregroundStyle(.accent)
            Text(count == 1 ? "1 place" : "\(count) places")
                .font(.rowDetail)
                .foregroundStyle(.textMuted)
        }
        .padding(.top, 18)
        .padding(.bottom, 6)
    }
}

private struct Row: View {

    let restaurant: Restaurant
    let isLast: Bool

    var body: some View {
        HStack(spacing: 14) {
            Thumbnail(url: URL(string: restaurant.photoUrl))
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(
                        AttributedString(
                            handwritten: restaurant.name,
                            brush: .brushSmall
                        )
                    )
                    .font(Font(UIFont.hand))
                    .foregroundStyle(.handwriting)
                    .lineLimit(1)
                    Text(detail)
                        .font(.small)
                        .foregroundStyle(.textMuted)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.textMuted)
            }
            .frame(maxHeight: .infinity)
            .overlay(alignment: .bottom) {
                if !isLast {
                    Rectangle()
                        .fill(.rule)
                        .frame(height: 1)
                }
            }
        }
        .frame(height: 72)
        .contentShape(.rect)
    }

    private var detail: String {
        let price = restaurant.priceLevel.map {
            String(repeating: "$", count: $0)
        }
        return [price, restaurant.category, restaurant.area]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: " · ")
    }
}

private struct Thumbnail: View {

    let url: URL?

    var body: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(.text.opacity(0.07))
            .frame(width: 48, height: 48)
            .overlay {
                if let url {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Color.clear
                    }
                } else {
                    Image(.bolobaoTransparent)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 34)
                        .opacity(0.5)
                }
            }
            .clipShape(.rect(cornerRadius: 6))
    }
}

private struct Empty: View {

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Nothing saved yet")
                .font(.messageTitle)
            Text(
                "Swipe a slip right or tap SAVE on the deck, and it lands here."
            )
            .font(.message)
        }
        .foregroundStyle(.text)
        .padding(.top, 18)
    }
}

private struct SavedSlip: View {

    let restaurant: Restaurant

    @Environment(SavedStore.self) private var saved
    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(spacing: 0) {
            Slip(restaurant: restaurant, showsAddress: true)
                .padding(.top, 20)
            DoneBar(isSaved: saved.contains(restaurant)) {
                if saved.contains(restaurant) {
                    saved.remove(restaurant)
                } else {
                    saved.save(restaurant)
                }
            } openMaps: {
                openURL(restaurant.mapsURL)
            }
        }
        .presentationBackground(.surface)
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(20)
    }
}
