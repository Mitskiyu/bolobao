import SwiftUI

struct AddPlace: View {

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                SheetHeader(title: "Add a place", button: "Cancel") {
                    dismiss()
                }
                Search()
            }
            .background(.surface)
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Place.self) { place in
                Writing(place: place, close: { dismiss() })
            }
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
