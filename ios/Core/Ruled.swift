import SwiftUI

extension View {

    func ruled(_ font: UIFont) -> some View {
        let top = Paper.baseline - font.ascender
        let spacing = Paper.line - font.lineHeight
        return
            self
            .font(Font(font))
            .lineSpacing(spacing)
            .padding(.top, top)
            .padding(.bottom, spacing - top)
    }
}

struct RuledRow: Layout {

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let size = subviews[0].sizeThatFits(proposal)
        let lines = max((size.height / Paper.line).rounded(), 1)
        return CGSize(width: size.width, height: lines * Paper.line)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        subviews[0].place(
            at: bounds.origin,
            proposal: ProposedViewSize(width: bounds.width, height: nil)
        )
    }
}
