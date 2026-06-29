import Foundation

@MainActor
final class SettingsStore: ObservableObject {
    @Published var defaultMinutes: Int {
        didSet { UserDefaults.standard.set(defaultMinutes, forKey: Keys.defaultMinutes) }
    }

    @Published var sessionMinutes: Int {
        didSet { UserDefaults.standard.set(sessionMinutes, forKey: Keys.sessionMinutes) }
    }

    private enum Keys {
        static let defaultMinutes = "defaultMinutes"
        static let sessionMinutes = "sessionMinutes"
    }

    init() {
        let storedDefault = UserDefaults.standard.integer(forKey: Keys.defaultMinutes)
        let resolvedDefault = storedDefault > 0 ? storedDefault : 25
        defaultMinutes = resolvedDefault

        let storedSession = UserDefaults.standard.integer(forKey: Keys.sessionMinutes)
        sessionMinutes = storedSession > 0 ? storedSession : resolvedDefault
    }

    func applyDefaultToSession() {
        sessionMinutes = defaultMinutes
    }
}
