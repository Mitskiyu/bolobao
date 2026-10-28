import SwiftUI

struct Search: View {

    enum SearchState {
        case empty, loading
        case results([Place])
        case noResults, failed
    }

    @State private var query = ""
    @State private var state: SearchState = .empty
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text("SHOP NAME")
                    .font(.label)
                    .tracking(0.8)
                    .foregroundStyle(.accent)
                TextField(
                    "Shop name",
                    text: $query,
                    prompt: Text("Type a shop's name")
                        .foregroundStyle(.textMuted)
                )
                .font(.field)
                .foregroundStyle(.text)
                .tint(.handwriting)
                .autocorrectionDisabled()
                .submitLabel(.search)
                .focused($isFocused)
                .padding(.horizontal, 14)
                .frame(height: 50)
                .background(.white, in: .rect(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(
                            isFocused ? .accent : .text,
                            lineWidth: isFocused ? 2 : 1.5
                        )
                }
            }
            .padding(.top, 14)
            .padding(.horizontal, Paper.gutter)
            SearchResults(state: state, query: query) {
                Task {
                    await search(query.trimmingCharacters(in: .whitespaces))
                }
            }
        }
        .onAppear {
            isFocused = true
        }
        .task(id: query) {
            let trimmed = query.trimmingCharacters(in: .whitespaces)
            guard trimmed.count >= 2 else {
                state = .empty
                return
            }

            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            await search(trimmed)
        }
    }

    private func search(_ text: String) async {
        state = .loading
        do {
            let places = try await Client.shared.search(text)
            state = places.isEmpty ? .noResults : .results(places)
        } catch {
            if !Task.isCancelled {
                state = .failed
            }
        }
    }
}

#Preview {
    Search()
        .background(.surface)
        .environment(SavedStore(folder: nil))
}
