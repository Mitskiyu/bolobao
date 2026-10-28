import SwiftUI

extension AttributedString {

    init(handwritten string: String, brush: UIFont) {
        self.init(string)
        for index in characters.indices where characters[index].isChinese {
            let next = characters.index(after: index)
            self[index..<next].font = Font(brush)
        }
        if !characters.isEmpty {
            let last = characters.index(before: endIndex)
            self[last..<endIndex].kern = 4
        }
    }
}

extension Character {

    fileprivate var isChinese: Bool {
        unicodeScalars.contains { scalar in
            scalar.properties.isIdeographic
                || (0x3000...0x303F).contains(scalar.value)
                || (0xFF00...0xFFEF).contains(scalar.value)
        }
    }
}
