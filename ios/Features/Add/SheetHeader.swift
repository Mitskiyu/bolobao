import SwiftUI

struct SheetHeader: View {

    var title = ""
    let button: String
    var isBack = false
    let action: () -> Void

    var body: some View {
        ZStack {
            Text(title)
                .font(.sheetTitle)
                .foregroundStyle(.text)
            HStack {
                Button(action: action) {
                    HStack(spacing: 6) {
                        if isBack {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .semibold))
                        }
                        Text(button)
                    }
                }
                .font(.sheetButton)
                .foregroundStyle(.accent)
                .padding(.horizontal, 8)
                .padding(.vertical, 10)
                Spacer()
            }
        }
        .padding(.horizontal, 12)
        .frame(height: 44)
        .padding(.top, 20)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(.surfaceMuted)
                .frame(height: 1)
        }
    }
}

#Preview {
    VStack(spacing: 0) {
        SheetHeader(title: "Add a place", button: "Cancel") {}
        SheetHeader(button: "Search", isBack: true) {}
    }
    .background(.surface)
}
