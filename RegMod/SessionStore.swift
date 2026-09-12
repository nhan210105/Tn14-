import Foundation
import Combine

@MainActor
final class SessionStore: ObservableObject {
    @Published private(set) var session = UserSession()
    @Published var apiKey = ""
    @Published var lastError: String?
    @Published var isLoading = false

    private let defaults = UserDefaults.standard
    private let apiKeyKey = "regmod.apiKey"
    private let sessionKey = "regmod.session"

    init() {
        apiKey = defaults.string(forKey: apiKeyKey) ?? ""
        if let data = defaults.data(forKey: sessionKey),
           let saved = try? JSONDecoder().decode(UserSession.self, from: data) {
            session = saved
        }
    }

    func setSession(username: String, tier: Int, blocked: Bool) {
        session = UserSession(username: username, tier: max(0, tier), blocked: blocked, authenticated: !blocked)
        save()
    }

    func save() {
        defaults.set(apiKey, forKey: apiKeyKey)
        if let data = try? JSONEncoder().encode(session) {
            defaults.set(data, forKey: sessionKey)
        }
    }

    func logout() {
        session = UserSession()
        save()
    }
}
