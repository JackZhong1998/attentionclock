import SwiftUI

struct ContentView: View {
    @ObservedObject var sessionStore: SessionStore
    @ObservedObject var settings: SettingsStore
    @StateObject private var timer: TimerViewModel

    init(sessionStore: SessionStore, settings: SettingsStore) {
        self.sessionStore = sessionStore
        self.settings = settings
        _timer = StateObject(wrappedValue: TimerViewModel(sessionStore: sessionStore, settings: settings))
    }

    var body: some View {
        TabView {
            TimerView(timer: timer, settings: settings)
                .tabItem {
                    Label("专注", systemImage: "timer")
                }

            StatsView(sessionStore: sessionStore)
                .tabItem {
                    Label("统计", systemImage: "chart.bar")
                }

            SettingsView(settings: settings, timer: timer)
                .tabItem {
                    Label("设置", systemImage: "gearshape")
                }
        }
        .frame(minWidth: 520, minHeight: 600)
    }
}
