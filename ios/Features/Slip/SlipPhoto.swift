import SwiftUI

struct SlipPhoto: View {

    let url: URL

    var body: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(.text.opacity(0.07))
            .frame(height: 210)
            .overlay {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.clear
                }
            }
            .clipShape(.rect(cornerRadius: 3))
            .padding(.horizontal, Paper.gutter)
    }
}
