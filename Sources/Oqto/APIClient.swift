import Foundation

struct APIClient {
    let baseURL: URL
    let apiKey: String

    private let session = URLSession.shared
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    func post<Body: Encodable, Response: Decodable>(_ path: String, body: Body) async throws -> Response {
        var request = URLRequest(url: baseURL.appending(path: path))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try encoder.encode(body)

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw OqtoError.invalidResponse }

        guard (200..<300).contains(http.statusCode) else {
            let apiError = try? decoder.decode(APIErrorResponse.self, from: data)
            throw OqtoError.server(status: http.statusCode,
                                   code: apiError?.error.code,
                                   message: apiError?.error.message)
        }
        return try decoder.decode(Response.self, from: data)
    }
}
