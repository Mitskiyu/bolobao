import SwiftUI

struct SearchResults: View {

    let state: Search.SearchState
    let query: String
    let retry: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                switch state {
                case .empty:
                    Note()
                        .padding(.top, 20)
                case .loading:
                    Header(isLoading: true)
                    VStack(spacing: 0) {
                        SkeletonRow(nameWidth: 184, detailWidth: 288)
                        SkeletonRow(nameWidth: 232, detailWidth: 256)
                        SkeletonRow(nameWidth: 160, detailWidth: 304)
                    }
                    .padding(.top, 4)
                case .results(let places):
                    Header()
                    VStack(spacing: 0) {
                        ForEach(places) { place in
                            NavigationLink(value: place) {
                                Row(place: place)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.top, 4)
                    Note()
                        .padding(.top, 20)
                case .noResults:
                    Header()
                    Message(
                        title: "No places with that name",
                        text:
                            "Nothing in Hong Kong matches “\(query)”. Check the spelling, or try just part of the name."
                    )
                case .failed:
                    Header()
                    Message(
                        title: "Can't search right now",
                        text:
                            "You might be offline, or Bolobao is having trouble. Check your connection and try again."
                    )
                    InkButton(title: "TRY AGAIN", action: retry)
                        .fixedSize()
                        .padding(.top, 18)
                }
            }
            .padding(.horizontal, Paper.gutter)
            .padding(.bottom, 20)
        }
        .scrollDismissesKeyboard(.interactively)
    }
}

#Preview("Empty") {
    SearchResults(state: .empty, query: "") {}
        .background(.surface)
}

#Preview("Loading") {
    SearchResults(state: .loading, query: "kam wah") {}
        .background(.surface)
}

#Preview("Results") {
    SearchResults(state: .results(Place.samples), query: "kam wah") {}
        .background(.surface)
}

#Preview("No results") {
    SearchResults(state: .noResults, query: "sun heung yuenn") {}
        .background(.surface)
}

#Preview("Failed") {
    SearchResults(state: .failed, query: "kam wah") {}
        .background(.surface)
}

extension Place {

    static let samples: [Place] = [
        Place(
            id: "1",
            name: "Kam Wah Café",
            category: "Cha Chaan Teng",
            address: "G/F, 45 Bute Street, Prince Edward, Kowloon",
            area: "Yau Tsim Mong",
            lat: 22.322296,
            lon: 114.16963,
            hasProfile: false
        ),
        Place(
            id: "2",
            name: "Kam Wah Café",
            category: "Cha Chaan Teng",
            address: "G/F, 47 Bute St",
            area: "Mong Kok",
            lat: 22.322275,
            lon: 114.169755,
            hasProfile: true
        ),
    ]
}

extension Place: Identifiable {}

private struct Header: View {

    var isLoading = false

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("PLACES IN HONG KONG")
                .font(.label)
                .tracking(0.8)
                .foregroundStyle(.accent)
            Spacer()
            if isLoading {
                Text("Searching…")
                    .font(.small)
                    .foregroundStyle(.textMuted)
            }
        }
        .padding(.top, 20)
    }
}

private struct Row: View {

    let place: Place

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(place.name)
                        .font(.rowTitle)
                        .foregroundStyle(.text)
                    if place.hasProfile {
                        Image(.tick)
                            .resizable()
                            .frame(width: 20, height: 18)
                            .foregroundStyle(.handwriting)
                    }
                }
                Text(
                    [place.category, place.area, place.address]
                        .filter { !$0.isEmpty }
                        .joined(separator: " · ")
                )
                .font(.rowDetail)
                .foregroundStyle(.textMuted)
                if !place.hasProfile {
                    Text("No slip yet. Tap to write one.")
                        .font(.small)
                        .foregroundStyle(.textMuted)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.textMuted)
        }
        .padding(.vertical, 10)
        .frame(minHeight: 72)
        .contentShape(.rect)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(.rule)
                .frame(height: 1)
        }
    }
}

private struct SkeletonRow: View {

    let nameWidth: CGFloat
    let detailWidth: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            RoundedRectangle(cornerRadius: 7)
                .fill(.text.opacity(0.1))
                .frame(width: nameWidth, height: 14)
            RoundedRectangle(cornerRadius: 5)
                .fill(.text.opacity(0.07))
                .frame(width: detailWidth, height: 10)
        }
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, minHeight: 72, alignment: .leading)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(.rule)
                .frame(height: 1)
        }
    }
}

private struct Message: View {

    let title: String
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.messageTitle)
            Text(text)
                .font(.message)
        }
        .foregroundStyle(.text)
        .padding(.top, 18)
    }
}

private struct Note: View {

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(
                "Pick a place and we'll read what people wrote, write its slip and check every line. It takes about a minute."
            )
            .font(.note)
            .foregroundStyle(.text)
            HStack(spacing: 4) {
                Text("Places with a")
                Image(.tick)
                    .resizable()
                    .frame(width: 17, height: 16)
                    .foregroundStyle(.handwriting)
                Text("already have a slip.")
            }
            .font(.small)
            .foregroundStyle(.textMuted)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.topBar, in: .rect(cornerRadius: 12))
    }
}
