import SwiftUI

@main
struct AttentionClockApp: App {
    @StateObject private var sessionStore = SessionStore()
    @StateObject private var settings = SettingsStore()
    @StateObject private var catStore = CatStore()

    var body: some Scene {
        WindowGroup {
            ContentView(
                sessionStore: sessionStore,
                settings: settings,
                catStore: catStore
            )
            .onAppear {
                FocusReminderService.shared.requestAuthorization()
            }
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 520, height: 600)
    }
}
