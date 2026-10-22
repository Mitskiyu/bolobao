import SwiftUI

extension Font {

    private static let handName = "BradleyHandITCTT-Bold"

    static let hand = Font.custom(handName, size: 24, relativeTo: .title2)
    static let handSmall = Font.custom(handName, size: 19, relativeTo: .body)
    static let label = Font.system(size: 11, weight: .bold)
    static let printedHeader = Font.system(size: 14, weight: .black)
    static let stamp = Font.system(size: 16, weight: .black)
    static let bigStamp = Font.system(size: 30, weight: .black)
}
