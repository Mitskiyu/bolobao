import Foundation

typealias Restaurant = Components.Schemas.RestaurantProfile
extension Restaurant: Identifiable {

    var seed: Int {
        id.unicodeScalars.reduce(0) { $0 + Int($1.value) }
    }

    var interleavedAnswers: [Answer] {
        let dishes = answers.filter(\.prompt.isDish)
        let others = answers.filter { !$0.prompt.isDish }
        var result: [Answer] = []
        for index in 0..<max(dishes.count, others.count) {
            if index < dishes.count {
                result.append(dishes[index])
            }
            if index < others.count {
                result.append(others[index])
            }
        }
        return result
    }
}

typealias Answer = Components.Schemas.Answer
typealias Prompt = Components.Schemas.Answer.PromptPayload
extension Prompt {

    var title: String {
        switch self {
        case .bestDish: "Best dish"
        case .whatToOrderFirst: "Order first"
        case .orderThisIfItsYourSecondTime: "Second time"
        case .orderThisNotThat: "Order this"
        case .whatToSkip: "Skip"
        case .knownFor: "Known for"
        case .portionSize: "Portions"
        case .valueForMoney: "Value"
        case .worthTheQueue: "The queue"
        case .waitTime: "Wait"
        case .busy: "Crowds"
        case .needToBook: "Booking"
        case .openingHours: "Hours"
        case .bestTime: "Best time"
        case .breakfast: "Breakfast"
        case .service: "Service"
        case .howOld: "History"
        case .cashOnly: "Paying"
        case .shareTable: "Seating"
        case .gettingThere: "Finding it"
        case .spiceLevel: "Spice"
        case .drinks: "Drinks"
        case .roomVibe: "Vibe"
        }
    }

    var isDish: Bool {
        switch self {
        case .bestDish, .whatToOrderFirst, .orderThisIfItsYourSecondTime,
            .orderThisNotThat, .whatToSkip:
            true
        default:
            false
        }
    }
}

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

extension Restaurant {

    var mapsURL: URL {
        var components = URLComponents(string: "https://maps.apple.com/")!
        components.queryItems = [
            URLQueryItem(name: "q", value: name),
            URLQueryItem(name: "ll", value: "\(lat),\(lon)"),
        ]
        return components.url!
    }
}
