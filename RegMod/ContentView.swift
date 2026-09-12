import SwiftUI
import UniformTypeIdentifiers
import UIKit

struct ContentView: View {
    @EnvironmentObject private var theme: ThemeManager
    @EnvironmentObject private var session: SessionStore
    @State private var selectedTab: AppTab = .cache
    @State private var selectedVersion: GameVersion = .freeFireMax
    @State private var showLogin = false
    @State private var toast: String?

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.black, Color(red: 0.04, green: 0.05, blue: 0.08)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            TabView(selection: $selectedTab) {
                CacheView(selectedVersion: $selectedVersion, toast: $toast)
                    .tabItem { Label("Cache", systemImage: "bolt.shield.fill") }
                    .tag(AppTab.cache)

                ShaderView(selectedVersion: $selectedVersion, toast: $toast)
                    .tabItem { Label("Shader", systemImage: "wand.and.stars") }
                    .tag(AppTab.shader)

                SettingsView(showLogin: $showLogin)
                    .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                    .tag(AppTab.settings)
            }
            .tint(.cyan)
        }
        .preferredColorScheme(theme.scheme)
        .sheet(isPresented: $showLogin) {
            LoginView()
                .environmentObject(session)
                        }
        .overlay(alignment: .top) {
            if let toast {
                ToastView(message: toast)
                    .padding(.top, 10)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .onTapGesture { self.toast = nil }
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: toast)
    }
}

struct CacheView: View {
    @Binding var selectedVersion: GameVersion
    @Binding var toast: String?
    @State private var showImporter = false
    @State private var selectedFile: URL?
    @State private var head = true
    @State private var magic = true
    @State private var radius = 1.07
    @State private var headDrag = 0.121

    private let presets = [
        CachePreset(id: "headshot", title: "Headshot", detail: "Ghim Headshot (cache chest/body)", imageName: "preset_headshot.jpg"),
        CachePreset(id: "magic", title: "Magic Bullet", detail: "Magic Bullet (magic cache)", imageName: "preset_magic.jpg"),
        CachePreset(id: "combo", title: "Combo: Headshot + Magic", detail: "Headshot + Magic 1.07m", imageName: "hitbox_mannequin.jpg")
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 14) {
                    HeaderCard(title: "TnCheats", subtitle: "Premium Mod & Cache Studio")
                    VersionPicker(selection: $selectedVersion)

                    ForEach(presets) { preset in
                        PresetCard(preset: preset) {
                            toast = "\(preset.title) selected"
                        }
                    }

                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Cache Controls", systemImage: "slider.horizontal.3")
                                .font(.headline)
                            Toggle("Headshot", isOn: $head)
                            Toggle("Magic Bullet", isOn: $magic)
                            VStack(alignment: .leading) {
                                Text("Head Drag: +\(headDrag, specifier: "%.3f")m")
                                Slider(value: $headDrag, in: -0.011...0.121)
                            }
                            VStack(alignment: .leading) {
                                Text("Spine Radius: \(radius, specifier: "%.2f")m")
                                Slider(value: $radius, in: 0.5...1.07)
                            }
                        }
                    }

                    Button {
                        showImporter = true
                    } label: {
                        ActionLabel(title: selectedFile == nil ? "Choose cache_res from device..." : "Cache file selected", icon: "arrow.down.doc.fill")
                    }
                    .buttonStyle(.plain)

                    Button {
                        toast = "EXPORT & SAVE CACHE — ready"
                    } label: {
                        ActionLabel(title: "EXPORT & SAVE CACHE", icon: "square.and.arrow.up.fill")
                    }
                    .buttonStyle(.plain)
                }
                .padding()
            }
            .navigationTitle("Cache")
            .fileImporter(isPresented: $showImporter,
                          allowedContentTypes: [.data, .item],
                          allowsMultipleSelection: false) { result in
                switch result {
                case .success(let urls):
                    selectedFile = urls.first
                    toast = "Cache file loaded"
                case .failure(let error):
                    toast = error.localizedDescription
                }
            }
        }
    }
}

struct ShaderView: View {
    @Binding var selectedVersion: GameVersion
    @Binding var toast: String?
    @EnvironmentObject private var session: SessionStore
    @State private var showImporter = false
    @State private var outline = 1.0
    @State private var backdrop = 1.0
    @State private var weaponColor = 0.8

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 14) {
                    HeaderCard(title: "TnCheats Shader", subtitle: "Customizer • X-Ray • Glow")
                    VersionPicker(selection: $selectedVersion)

                    if session.session.tier < 1 {
                        GlassCard {
                            VStack(alignment: .leading, spacing: 10) {
                                Label("VIP EXCLUSIVE FEATURE", systemImage: "lock.shield.fill")
                                    .font(.headline)
                                Text("Shader tab requires an account granted VIP status (Tier 1) by Admin.")
                                    .foregroundStyle(.secondary)
                                Text("Current Account: FREE USER (TIER 0)")
                                    .font(.subheadline.weight(.semibold))
                            }
                        }
                    }

                    GlassCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Colors & Backdrop Configuration").font(.headline)
                            SliderRow(title: "Outline & Backdrop Thickness", value: $outline)
                            SliderRow(title: "Backdrop Poster Color", value: $backdrop)
                            SliderRow(title: "Weapon Base Color", value: $weaponColor)
                        }
                    }

                    Button {
                        showImporter = true
                    } label: {
                        ActionLabel(title: "GENERATE SHADER MOD", icon: "wand.and.stars")
                    }
                    .buttonStyle(.plain)
                }
                .padding()
            }
            .navigationTitle("Shader")
            .fileImporter(isPresented: $showImporter, allowedContentTypes: [.data, .item]) { result in
                switch result {
                case .success:
                    toast = "Shader file selected"
                case .failure(let error):
                    toast = error.localizedDescription
                }
            }
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject private var theme: ThemeManager
    @EnvironmentObject private var session: SessionStore
    @Binding var showLogin: Bool

    var body: some View {
        NavigationView {
            Form {
                Section("Account") {
                    HStack {
                        Image(systemName: "person.crop.circle.fill")
                        VStack(alignment: .leading) {
                            Text(session.session.authenticated ? session.session.username : "FREE USER")
                            Text("TIER \(session.session.tier)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    Button(session.session.authenticated ? "Logout" : "Login / Register") {
                        if session.session.authenticated { session.logout() } else { showLogin = true }
                    }
                }

                Section("Appearance") {
                    Toggle("Dark Mode", isOn: $theme.darkMode)
                }

                Section("API Key") {
                    SecureField("API Key", text: $session.apiKey)
                        .textInputAutocapitalization(.never)
                    Button("Save API Key") { session.save() }
                }

                Section("Version Information") {
                    HStack {
                        Text("App")
                        Spacer()
                        Text("TnCheats").foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("2.0.3").foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("iOS")
                        Spacer()
                        Text("15.0+").foregroundStyle(.secondary)
                    }
                }

                Section("Contact") {
                    Button("Copy Telegram Link") {
                        UIPasteboard.general.string = "https://t.me/truongdeptrai7"
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var session: SessionStore
    @State private var username = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var loading = false

    var body: some View {
        NavigationView {
            Form {
                Section("Authentication") {
                    TextField("Username", text: $username)
                        .textInputAutocapitalization(.never)
                    SecureField("Password", text: $password)
                }
                if let errorMessage {
                    Text(errorMessage).foregroundStyle(.red)
                }
                Button(loading ? "Checking..." : "LOGIN NOW") {
                    login()
                }
                .disabled(loading || username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .navigationTitle("Login")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private func login() {
        loading = true
        errorMessage = nil
        // The original binary's endpoint requires server-side credentials/HWID.
        // Keep the UI non-crashing when the endpoint is unreachable or returns malformed JSON.
        APIService.shared.verify(apiKey: session.apiKey) { result in
            DispatchQueue.main.async {
                loading = false
                switch result {
                case .success(let response):
                    if response.success == true {
                        session.session = UserSession(username: username,
                                                      tier: response.tier ?? 0,
                                                      blocked: response.blocked ?? false,
                                                      authenticated: true)
                        session.save()
                        dismiss()
                    } else {
                        errorMessage = response.message ?? "Authentication failed."
                    }
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}

struct HeaderCard: View {
    let title: String
    let subtitle: String
    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.system(size: 28, weight: .black, design: .rounded))
                Text(subtitle).foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct VersionPicker: View {
    @Binding var selection: GameVersion
    var body: some View {
        GlassCard {
            Picker("Select Game Version", selection: $selection) {
                ForEach(GameVersion.allCases) { version in
                    Text(version.title).tag(version)
                }
            }
            .pickerStyle(.segmented)
        }
    }
}

struct PresetCard: View {
    let preset: CachePreset
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            GlassCard {
                HStack(spacing: 12) {
                    if UIImage(named: preset.imageName) != nil {
                        Image(preset.imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 68, height: 68)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    VStack(alignment: .leading, spacing: 5) {
                        Text(preset.title).font(.headline)
                        Text(preset.detail).font(.subheadline).foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

struct SliderRow: View {
    let title: String
    @Binding var value: Double
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
            Slider(value: $value, in: 0...2)
        }
    }
}

struct ActionLabel: View {
    let title: String
    let icon: String
    var body: some View {
        HStack {
            Image(systemName: icon)
            Text(title).fontWeight(.semibold)
            Spacer()
            Image(systemName: "arrow.right.circle.fill")
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(.white.opacity(0.08)))
    }
}

struct GlassCard<Content: View>: View {
    @ViewBuilder let content: Content
    var body: some View {
        content
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(.white.opacity(0.08)))
    }
}

struct ToastView: View {
    let message: String
    var body: some View {
        Text(message)
            .font(.subheadline.weight(.semibold))
            .padding(.horizontal, 16)
            .padding(.vertical, 11)
            .background(.regularMaterial, in: Capsule())
            .shadow(radius: 14)
    }
}
