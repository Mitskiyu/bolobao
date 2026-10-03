import Foundation

typealias Restaurant = Components.Schemas.Restaurant
extension Restaurant: Identifiable {}

typealias Prompt = Components.Schemas.Answer.PromptPayload
extension Prompt {

    var title: String {
        rawValue.replacingOccurrences(of: "_", with: " ").capitalized
    }
}

#if DEBUG
    extension Restaurant {

        static let samples: [Restaurant] = {
            struct Page: Decodable {

                let data: [Restaurant]
            }

            let url = Bundle.main.url(
                forResource: "restaurants",
                withExtension: "json"
            )!
            let data = try! Data(contentsOf: url)
            return try! JSONDecoder()
                .decode(Page.self, from: data)
                .data
        }()

        static let sample = samples[0]
    }
#endif
