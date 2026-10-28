import SwiftUI

struct TopBar: View {

    var body: some View {
        HStack(spacing: 10) {
            Image(.bolobaoTransparent)
                .resizable()
                .scaledToFit()
                .frame(height: 40)
                .offset(y: -3)
            Text("Bolobao")
                .font(.wordmark)
                .tracking(0.5)
                .foregroundStyle(.accent)
            Spacer()
        }
        .padding(.horizontal, Paper.gutter)
        .frame(height: 52)
        .background(.topBar)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(.surfaceMuted)
                .frame(height: 1)
        }
    }
}

#Preview {
    TopBar()
}
