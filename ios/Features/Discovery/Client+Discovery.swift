import Foundation
import OpenAPIURLSession

extension Client {

    static let shared = Client(
        serverURL: Config.url,
        transport: URLSessionTransport()
    )

    func restaurants(cursor: String? = nil, limit: Int? = nil) async throws
        -> [Restaurant]
    {
        let resp = try await listProfiles(
            query: .init(after: cursor, limit: limit)
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
