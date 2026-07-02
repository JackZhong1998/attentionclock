import Foundation

@MainActor
final class SettingsStore: ObservableObject {
    @Published var defaultMinutes: Int {
        didSet { UserDefaults.standard.set(defaultMinutes, forKey: Keys.defaultMinutes) }
    }

    @Published var sessionMinutes: Int {
        didSet { UserDefaults.standard.set(sessionMinutes, forKey: Keys.sessionMinutes) }
    }

    @Published var desktopPetEnabled: Bool {
        didSet {
            UserDefaults.standard.set(desktopPetEnabled, forKey: Keys.desktopPetEnabled)
            if !desktopPetEnabled {
                floatingCatEnabled = false
            }
        }
    }

    @Published var floatingCatEnabled: Bool {
        didSet { UserDefaults.standard.set(floatingCatEnabled, forKey: Keys.floatingCatEnabled) }
    }

    @Published var floatingCatOriginX: Double {
        didSet { UserDefaults.standard.set(floatingCatOriginX, forKey: Keys.floatingCatOriginX) }
    }

    @Published var floatingCatOriginY: Double {
        didSet { UserDefaults.standard.set(floatingCatOriginY, forKey: Keys.floatingCatOriginY) }
    }

    @Published var floatingCatPositionSaved: Bool {
        didSet { UserDefaults.standard.set(floatingCatPositionSaved, forKey: Keys.floatingCatPositionSaved) }
    }

    private enum Keys {
        static let defaultMinutes = "defaultMinutes"
        static let sessionMinutes = "sessionMinutes"
        static let desktopPetEnabled = "desktopPetEnabled"
        static let floatingCatEnabled = "floatingCatEnabled"
        static let floatingCatOriginX = "floatingCatOriginX"
        static let floatingCatOriginY = "floatingCatOriginY"
        static let floatingCatPositionSaved = "floatingCatPositionSaved"
    }

    init() {
        let storedDefault = UserDefaults.standard.integer(forKey: Keys.defaultMinutes)
        let resolvedDefault = storedDefault > 0 ? storedDefault : 25
        defaultMinutes = resolvedDefault

        let storedSession = UserDefaults.standard.integer(forKey: Keys.sessionMinutes)
        sessionMinutes = storedSession > 0 ? storedSession : resolvedDefault

        desktopPetEnabled = UserDefaults.standard.object(forKey: Keys.desktopPetEnabled) as? Bool ?? false
        floatingCatEnabled = UserDefaults.standard.bool(forKey: Keys.floatingCatEnabled)
        floatingCatOriginX = UserDefaults.standard.double(forKey: Keys.floatingCatOriginX)
        floatingCatOriginY = UserDefaults.standard.double(forKey: Keys.floatingCatOriginY)
        floatingCatPositionSaved = UserDefaults.standard.bool(forKey: Keys.floatingCatPositionSaved)
    }

    func applyDefaultToSession() {
        sessionMinutes = defaultMinutes
    }
}
