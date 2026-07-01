import SwiftUI

struct ContentView: View {
    @ObservedObject var sessionStore: SessionStore
    @ObservedObject var settings: SettingsStore
    @ObservedObject var catStore: CatStore
    @ObservedObject var petStore: PetStore
    @StateObject private var timer: TimerViewModel

    init(sessionStore: SessionStore, settings: SettingsStore, catStore: CatStore, petStore: PetStore) {
        self.sessionStore = sessionStore
        self.settings = settings
        self.catStore = catStore
        self.petStore = petStore
        _timer = StateObject(wrappedValue: TimerViewModel(
            sessionStore: sessionStore,
            settings: settings,
            catStore: catStore
        ))
    }

    var body: some View {
        TabView {
            TimerView(timer: timer, settings: settings, catStore: catStore, petStore: petStore)
                .tabItem {
                    Label("专注", systemImage: "timer")
                }

            DesktopPetView(
                settings: settings,
                petStore: petStore,
                catStore: catStore,
                timer: timer
            )
            .tabItem {
                Label("专注伙伴", systemImage: "person.2.fill")
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
        .onChange(of: settings.desktopPetEnabled) { _, _ in
            syncFloatingWindow()
        }
        .onChange(of: settings.floatingCatEnabled) { _, _ in
            syncFloatingWindow()
        }
        .onChange(of: petStore.selectedPetId) { _, _ in
            syncFloatingWindow()
        }
    }

    private func syncFloatingWindow() {
        let shouldShow = settings.desktopPetEnabled && settings.floatingCatEnabled && petStore.hasSelectedPet
        FloatingCatWindowController.shared.sync(
            enabled: shouldShow,
            petStore: petStore,
            catStore: catStore,
            timer: timer
        )
    }
}
