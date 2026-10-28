import SwiftUI

struct DoneBar: View {

    let isSaved: Bool
    let toggle: () -> Void
    let openMaps: () -> Void

    var body: some View {
        Panel(top: 14) {
            HStack(spacing: 14) {
                InkButton(
                    title: isSaved ? "SAVED" : "SAVE",
                    icon: isSaved ? Image(systemName: "checkmark") : nil,
                    isFilled: false,
                    tilt: 1.5,
                    action: toggle
                )
                .frame(width: 150)
                InkButton(
                    title: "OPEN IN MAPS",
                    icon: Image(.mapPin),
                    color: .handwriting,
                    action: openMaps
                )
            }
        }
    }
}
