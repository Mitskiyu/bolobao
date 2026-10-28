import SwiftUI

struct InkButton: View {

    let title: String
    var icon: Image?
    var color: Color = .accent
    var isFilled = true
    var tilt: Double = -1.5
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon {
                    icon
                        .resizable()
                        .scaledToFit()
                        .frame(width: 17, height: 17)
                }
                Text(title)
                    .font(.inkButton)
                    .tracking(2.5)
            }
            .foregroundStyle(isFilled ? .surface : color)
            .padding(.horizontal, 28)
            .frame(height: 54)
            .frame(maxWidth: .infinity)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color)
                    .overlay {
                        if isFilled {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.black.opacity(0.2))
                        }
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 5.5)
                            .fill(isFilled ? color : .surface)
                            .padding(
                                EdgeInsets(
                                    top: 2,
                                    leading: 2.5,
                                    bottom: 3,
                                    trailing: 2.5
                                )
                            )
                    }
            }
            .rotationEffect(.degrees(tilt))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack(spacing: 20) {
        HStack(spacing: 14) {
            InkButton(
                title: "CLOSE",
                color: .textMuted,
                isFilled: false,
                tilt: 1.5
            ) {}
            .frame(width: 148)
            InkButton(title: "TRY AGAIN") {}
        }
        HStack(spacing: 14) {
            InkButton(
                title: "SAVED",
                icon: Image(systemName: "checkmark"),
                isFilled: false,
                tilt: 1.5
            ) {}
            .frame(width: 150)
            InkButton(
                title: "OPEN IN MAPS",
                icon: Image(.mapPin),
                color: .handwriting
            ) {}
        }
    }
    .padding()
    .background(.surface)
}
