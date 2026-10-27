import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

typealias Place = Components.Schemas.Restaurant
typealias ProfileEvent = Components.Schemas.ProfileEvent
typealias Phase = Components.Schemas.ProfileEvent.PhasePayload

extension Client {

    static let writer: Client = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 180
        return Client(
            serverURL: Config.url,
            transport: URLSessionTransport(
                configuration: .init(
                    session: URLSession(configuration: configuration)
                )
            )
        )
    }()

    func search(_ query: String) async throws -> [Place] {
        let resp = try await searchRestaurants(query: .init(q: query))
        switch resp {
        case .ok(let ok):
            return try ok.body.json.data
        case .badRequest(let err):
            throw try err.body.json.code
        case .internalServerError(let err):
            throw try err.body.json.code
        case .undocumented(let statusCode, _):
            throw UnexpectedStatus(code: statusCode)
        }
    }

    func createProfile(id: String) async throws
        -> some AsyncSequence<ProfileEvent, any Error>
    {
        let resp = try await createRestaurantProfile(path: .init(id: id))
        switch resp {
        case .ok(let ok):
            return try ok.body.textEventStream
                .asDecodedServerSentEventsWithJSONData(of: ProfileEvent.self)
                .compactMap(\.data)
        case .badRequest(let err):
            throw try err.body.json.code
        case .notFound(let err):
            throw try err.body.json.code
        case .tooManyRequests(let err):
            throw try err.body.json.code
        case .internalServerError(let err):
            throw try err.body.json.code
        case .serviceUnavailable(let err):
            throw try err.body.json.code
        case .undocumented(let statusCode, _):
            throw UnexpectedStatus(code: statusCode)
        }
    }
}
