import SwiftUI
import Combine

@MainActor
final class ThemeManager: ObservableObject {
    @Published var darkMode: Bool = UserDefaults.standard.object(forKey: "regmod.darkMode") as? Bool ?? true {
        didSet { UserDefaults.standard.set(darkMode, forKey: "regmod.darkMode") }
    }

    var scheme: ColorScheme { darkMode ? .dark : .light }
}
