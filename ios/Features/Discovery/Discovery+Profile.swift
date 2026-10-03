import SwiftUI

extension Discovery {

    struct Profile: View {

        let restaurant: Restaurant

        var body: some View {
            Grid(
                alignment: .leadingFirstTextBaseline,
                horizontalSpacing: 12,
                verticalSpacing: 8
            ) {
                GridRow {
                    Text("Name").font(.headline)
                    Text(restaurant.name)
                }
                GridRow {
                    Text("Place").font(.headline)
                    Text("\(restaurant.category) · \(restaurant.area)")
                        .fixedSize(horizontal: false, vertical: true)
                }
                Divider()
                ForEach(restaurant.answers, id: \.prompt) { answer in
                    GridRow {
                        Text(answer.prompt.title).font(.headline)
                        Text(answer.text)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    Discovery.Profile(restaurant: Restaurant.sample)
}
