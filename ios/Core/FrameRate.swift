import QuartzCore

@MainActor
final class FrameRate: NSObject {

    static let shared = FrameRate()

    private var link: CADisplayLink?

    func boost() {
        guard link == nil else { return }
        let link = CADisplayLink(target: self, selector: #selector(tick))
        link.preferredFrameRateRange = CAFrameRateRange(
            minimum: 80,
            maximum: 120,
            preferred: 120
        )
        link.add(to: .main, forMode: .common)
        self.link = link
    }

    func reset() {
        link?.invalidate()
        link = nil
    }

    @objc private func tick(_ link: CADisplayLink) {}
}
