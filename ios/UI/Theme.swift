import SwiftUI

extension UIFont {

    static let hand = UIFont(name: "Caveat-Bold", size: 24)!
    static let handLarge = UIFont(name: "Caveat-Bold", size: 32)!
    static let handSmall = UIFont(name: "Caveat-Bold", size: 23)!
    static let brush = UIFont(name: "LXGWWenKaiTC-Bold", size: 22)!
    static let brushSmall = UIFont(name: "LXGWWenKaiTC-Bold", size: 21)!
    static let answer = UIFont(name: "NotoSansHK-Regular", size: 17)!
    static let label = UIFont(name: "NotoSansHK-Bold", size: 11)!
    static let welcome = UIFont(name: "NotoSansHK-Black", size: 46)!
    static let printedHeader = UIFont(name: "NotoSansHK-Black", size: 14)!
}

extension Font {

    static let wordmark = Font.custom("NotoSansHK-Black", fixedSize: 22)
    static let printedHeader = Font.custom("NotoSansHK-Black", fixedSize: 14)
    static let small = Font.custom("NotoSansHK-Regular", fixedSize: 13)
    static let tab = Font.custom("NotoSansHK-Regular", fixedSize: 11)
    static let tabSelected = Font.custom("NotoSansHK-Bold", fixedSize: 11)
    static let sheetTitle = Font.custom("NotoSansHK-Bold", fixedSize: 17)
    static let sheetButton = Font.custom("NotoSansHK-Regular", fixedSize: 17)
    static let label = Font.custom("NotoSansHK-Bold", fixedSize: 11)
    static let field = Font.custom("NotoSansHK-Regular", fixedSize: 17)
    static let note = Font.custom("NotoSansHK-Regular", fixedSize: 15)
    static let rowTitle = Font.custom("NotoSansHK-Bold", fixedSize: 17)
    static let rowDetail = Font.custom("NotoSansHK-Regular", fixedSize: 14)
    static let messageTitle = Font.custom("NotoSansHK-Bold", fixedSize: 20)
    static let message = Font.custom("NotoSansHK-Regular", fixedSize: 16)
    static let inkButton = Font.custom("NotoSansHK-Black", fixedSize: 16)
    static let slipStatus = Font.custom("NotoSansHK-Bold", fixedSize: 12)
    static let step = Font.custom("NotoSansHK-Regular", fixedSize: 16)
    static let stepCurrent = Font.custom("NotoSansHK-Bold", fixedSize: 16)

    static func hand(_ size: CGFloat) -> Font {
        .custom("Caveat-Bold", fixedSize: size)
    }
}
