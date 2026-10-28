import SwiftUI

struct Panel<Content: View>: View {

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
