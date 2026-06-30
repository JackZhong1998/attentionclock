import Foundation

@MainActor
final class SettingsStore: ObservableObject {
    @Published var defaultMinutes: Int {
        didSet { UserDefaults.standard.set(defaultMinutes, forKey: Keys.defaultMinutes) }
    }

    @Published var sessionMinutes: Int {
        didSet { UserDefaults.standard.set(sessionMinutes, forKey: Keys.sessionMinutes) }
    }

    @Published var cloudCatEnabled: Bool {
        didSet {
            UserDefaults.standard.set(cloudCatEnabled, forKey: Keys.cloudCatEnabled)
            if !cloudCatEnabled {
                floatingCatEnabled = false
            }
        }
    }

    @Published var floatingCatEnabled: Bool {
        didSet { UserDefaults.standard.set(floatingCatEnabled, forKey: Keys.floatingCatEnabled) }
    }

    private enum Keys {
        static let defaultMinutes = "defaultMinutes"
        static let sessionMinutes = "sessionMinutes"
        static let cloudCatEnabled = "cloudCatEnabled"
        static let floatingCatEnabled = "floatingCatEnabled"
    }

    init() {
        let storedDefault = UserDefaults.standard.integer(forKey: Keys.defaultMinutes)
        let resolvedDefault = storedDefault > 0 ? storedDefault : 25
        defaultMinutes = resolvedDefault

        let storedSession = UserDefaults.standard.integer(forKey: Keys.sessionMinutes)
        sessionMinutes = storedSession > 0 ? storedSession : resolvedDefault

        cloudCatEnabled = UserDefaults.standard.bool(forKey: Keys.cloudCatEnabled)
        floatingCatEnabled = UserDefaults.standard.bool(forKey: Keys.floatingCatEnabled)
    }

    func applyDefaultToSession() {
        sessionMinutes = defaultMinutes
    }
}
