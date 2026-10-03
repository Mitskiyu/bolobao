import Foundation
import OpenAPIURLSession

extension Client {

    static let shared = Client(
        serverURL: Config.url,
        transport: URLSessionTransport()
    )

    func restaurants(cursor: UUID? = nil, limit: Int? = nil) async throws
        -> [Restaurant]
    {
        let resp = try await listRestaurants(
            query: .init(after: cursor?.uuidString, limit: limit)
        )
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
}
