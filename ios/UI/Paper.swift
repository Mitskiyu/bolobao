import SwiftUI

struct Paper: View {

    static let line: CGFloat = 32
    static let baseline: CGFloat = 23
    static let rule: CGFloat = 25
    static let gutter: CGFloat = 20
    static let labelWidth: CGFloat = 96
    static let columnGap: CGFloat = 14
    static let margin = gutter + labelWidth + columnGap / 2

    var scrolled: CGFloat = 0
    var showsMargin = true

    var body: some View {
        Canvas { context, size in
            let top = max(-scrolled, 0)
            let hidden = max(
                ((scrolled - Paper.rule) / Paper.line).rounded(.up), 0)
            let first = Paper.rule - scrolled + hidden * Paper.line

            var rules = Path()
            for y in stride(from: first, to: size.height, by: Paper.line) {
                rules.addRect(CGRect(x: 0, y: y, width: size.width, height: 1))
            }
            context.fill(rules, with: .color(.rule))
            guard showsMargin else { return }

            let margin = CGRect(
                x: Paper.margin,
                y: top,
                width: 1,
                height: size.height - top
            )
            context.fill(Path(margin), with: .color(.ruleAccent))
        }
    }
}
