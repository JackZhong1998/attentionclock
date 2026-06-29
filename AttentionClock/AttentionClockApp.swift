import SwiftUI

@main
struct AttentionClockApp: App {
    @StateObject private var sessionStore = SessionStore()
    @StateObject private var settings = SettingsStore()

    var body: some Scene {
        WindowGroup {
            ContentView(sessionStore: sessionStore, settings: settings)
                .onAppear {
                    FocusReminderService.shared.requestAuthorization()
                }
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 480, height: 600)
    }
}
