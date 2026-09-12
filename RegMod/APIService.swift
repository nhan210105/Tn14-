import Foundation

struct APIResponse: Decodable {
    let success: Bool?
    let message: String?
    let tier: Int?
    let blocked: Bool?

    enum CodingKeys: String, CodingKey {
        case success, message, tier, blocked
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        // The original app contains Swift Array/JSON casts that can terminate the process
        // when the VPS returns a different JSON shape. Every field is intentionally tolerant.
        success = try? c.decodeIfPresent(Bool.self, forKey: .success)
        message = try? c.decodeIfPresent(String.self, forKey: .message)
        tier = try? c.decodeIfPresent(Int.self, forKey: .tier)
        blocked = try? c.decodeIfPresent(Bool.self, forKey: .blocked)
    }
}

enum APIError: LocalizedError {
    case invalidServerURL
    case invalidResponse
    case http(Int, String?)
    case malformedResponse

    var errorDescription: String? {
        switch self {
        case .invalidServerURL: return "Invalid Server URL"
        case .invalidResponse: return "Invalid server response."
        case .http(let code, let message): return message ?? "Server returned HTTP \(code)."
        case .malformedResponse: return "Server returned an unsupported response."
        }
    }
}

final class APIService {
    static let shared = APIService()
    private let serverURL = "http://103.238.234.204:6789"
    private let session: URLSession

    private init() {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 12
        config.timeoutIntervalForResource = 20
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        session = URLSession(configuration: config)
    }

    func verify(apiKey: String, completion: @escaping (Result<APIResponse, Error>) -> Void) {
        request(path: "/api/verify_hwid", body: ["api_key": apiKey], completion: completion)
    }

    private func request(path: String, body: [String: Any], completion: @escaping (Result<APIResponse, Error>) -> Void) {
        guard let url = URL(string: serverURL + path) else {
            DispatchQueue.main.async { completion(.failure(APIError.invalidServerURL)) }
            return
        }

        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 12)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            DispatchQueue.main.async { completion(.failure(error)) }
            return
        }

        session.dataTask(with: request) { data, response, error in
            if let error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            guard let http = response as? HTTPURLResponse, let data else {
                DispatchQueue.main.async { completion(.failure(APIError.invalidResponse)) }
                return
            }

            guard (200...299).contains(http.statusCode) else {
                let message = Self.safeMessage(from: data)
                DispatchQueue.main.async { completion(.failure(APIError.http(http.statusCode, message))) }
                return
            }

            do {
                let decoded = try JSONDecoder().decode(APIResponse.self, from: data)
                DispatchQueue.main.async { completion(.success(decoded)) }
            } catch {
                // Never force-cast an arbitrary server JSON array/dictionary.
                DispatchQueue.main.async { completion(.failure(APIError.malformedResponse)) }
            }
        }.resume()
    }

    private static func safeMessage(from data: Data) -> String? {
        guard let object = try? JSONSerialization.jsonObject(with: data, options: []) else { return nil }
        if let dict = object as? [String: Any] {
            return dict["message"] as? String ?? dict["error"] as? String
        }
        return nil
    }
}
