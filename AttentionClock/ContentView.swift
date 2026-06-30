import SwiftUI

struct ContentView: View {
    @ObservedObject var sessionStore: SessionStore
    @ObservedObject var settings: SettingsStore
    @ObservedObject var catStore: CatStore
    @StateObject private var timer: TimerViewModel

    init(sessionStore: SessionStore, settings: SettingsStore, catStore: CatStore) {
        self.sessionStore = sessionStore
        self.settings = settings
        self.catStore = catStore
        _timer = StateObject(wrappedValue: TimerViewModel(
            sessionStore: sessionStore,
            settings: settings,
            catStore: catStore
        ))
    }

    var body: some View {
        TabView {
            TimerView(timer: timer, settings: settings, catStore: catStore)
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
        .onAppear {
            syncFloatingWindow()
        }
        .onChange(of: settings.cloudCatEnabled) { _, _ in
            syncFloatingWindow()
        }
        .onChange(of: settings.floatingCatEnabled) { _, _ in
            syncFloatingWindow()
        }
    }

    private func syncFloatingWindow() {
        let shouldShow = settings.cloudCatEnabled && settings.floatingCatEnabled
        FloatingCatWindowController.shared.sync(
            enabled: shouldShow,
            catStore: catStore,
            timer: timer
        )
    }
}
