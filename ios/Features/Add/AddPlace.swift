import SwiftUI

struct AddPlace: View {

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            Header(title: "Add a place") { dismiss() }
            Search()
        }
        .presentationBackground(.surface)
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(20)
    }
}

#Preview {
    Color.canvas
        .sheet(isPresented: .constant(true)) {
            AddPlace()
        }
}

private struct Header: View {

    let title: String
    let cancel: () -> Void

    var body: some View {
        ZStack {
            Text(title)
                .font(.sheetTitle)
                .foregroundStyle(.text)
            HStack {
                Button("Cancel", action: cancel)
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
