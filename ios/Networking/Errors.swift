typealias ErrorCode = Components.Schemas.ErrorResponse.CodePayload
extension ErrorCode: Error {}

struct UnexpectedStatus: Error {

    let code: Int
}
