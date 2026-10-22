import SwiftUI

struct PenCircle: Shape {

    var seed = 0

    func path(in rect: CGRect) -> Path {
        let start = (-0.95 + 0.6 * random(1)) * Double.pi
        let sweep = (2.08 + 0.22 * random(2)) * Double.pi
        let growth = 0.08 + 0.14 * random(3)
        let wobble = 2 * Double.pi * random(4)
        let steps = 72

        var path = Path()
        for step in 0...steps {
            let progress = Double(step) / Double(steps)
            let angle = start + progress * sweep
            let widen =
                1 - growth / 2 + growth * progress
                + 0.035 * sin(3 * angle + wobble)
            let point = CGPoint(
                x: rect.midX + rect.width / 2 * widen * cos(angle),
                y: rect.midY + rect.height / 2 * widen * sin(angle)
            )
            if step == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        return path
    }

    private func random(_ salt: Double) -> Double {
        let value = sin(Double(seed) * 12.9898 + salt * 78.233) * 43758.5453
        return value - value.rounded(.down)
    }
}

#Preview {
    HStack {
        ForEach(0..<4) { seed in
            Text("$$")
                .font(.hand(24))
                .padding(12)
                .overlay {
                    PenCircle(seed: seed)
                        .stroke(
                            .handwriting,
                            style: StrokeStyle(lineWidth: 2, lineCap: .round)
                        )
                }
        }
    }
}
