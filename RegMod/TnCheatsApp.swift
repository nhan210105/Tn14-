import SwiftUI
import UIKit

@main
struct TnCheatsApp: App {
    @StateObject private var theme = ThemeManager()
    @StateObject private var session = SessionStore()

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(theme)
                .environmentObject(session)
        }
    }
}
