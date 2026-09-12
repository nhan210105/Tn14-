import Foundation

enum GameVersion: String, CaseIterable, Identifiable {
    case freeFire = "com.dts.freefireth"
    case freeFireMax = "com.dts.freefiremax"
    var id: String { rawValue }
    var title: String {
        switch self {
        case .freeFire: return "Free Fire (FFT)"
        case .freeFireMax: return "Free Fire MAX (FFM)"
        }
    }
}

enum AppTab: Hashable { case cache, shader, settings }

struct CachePreset: Identifiable, Hashable {
    let id: String
    let title: String
    let detail: String
    let imageName: String
}

struct UserSession: Codable {
    var username = ""
    var tier = 0
    var blocked = false
    var authenticated = false
}

struct GunModConfig: Codable {
    var outline = 1.0
    var backdrop = 1.0
    var weaponColor = 0.8
}
