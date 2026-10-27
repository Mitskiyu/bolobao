import SwiftUI

struct InkButton: View {

    let title: String
    var color: Color = .accent
    var isFilled = true
    var tilt: Double = -1.5
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.inkButton)
                .tracking(2.5)
                .foregroundStyle(isFilled ? .surface : color)
                .padding(.horizontal, 28)
                .frame(height: 54)
                .frame(maxWidth: .infinity)
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isFilled ? color : .surface.opacity(0.92))
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(color, lineWidth: 2.5)
                }
                .rotationEffect(.degrees(tilt))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HStack(spacing: 14) {
        InkButton(title: "CLOSE", color: .textMuted, isFilled: false) {}
        InkButton(title: "TRY AGAIN", tilt: 1.5) {}
    }
    .padding()
    .background(.surface)
}
