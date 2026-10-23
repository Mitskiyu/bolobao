import Foundation

enum Config {

    static let url: URL = {
        let string =
            Bundle.main.object(forInfoDictionaryKey: "API_URL") as! String
        return URL(string: string)!
    }()
}
