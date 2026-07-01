import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: SettingsStore
    @ObservedObject var timer: TimerViewModel

    var body: some View {
        Form {
            Section {
                Stepper(value: defaultMinutesBinding, in: 5...180, step: 5) {
                    HStack {
                        Text("默认时长")
                        Spacer()
                        Text(L10n.minutes(settings.defaultMinutes))
                            .foregroundStyle(.secondary)
                    }
                }

                if timer.canAdjustDuration {
                    Stepper(value: sessionMinutesBinding, in: 1...180, step: 1) {
                        HStack {
                            Text("本次时长")
                            Spacer()
                            Text(L10n.minutes(settings.sessionMinutes))
                                .foregroundStyle(.secondary)
                        }
                    }
                } else {
                    HStack {
                        Text("本次时长")
                        Spacer()
                        Text(L10n.minutes(settings.sessionMinutes))
                            .foregroundStyle(.secondary)
                    }
                }

                Button("恢复为默认时长") {
                    settings.applyDefaultToSession()
                    timer.syncFromSettings()
                }
                .disabled(!timer.canAdjustDuration)
            } header: {
                Text("倒计时")
            } footer: {
                Text("默认时长会在每次专注结束后自动应用。打开应用后可直接点击「开始专注」，或先调整本次时长。")
            }

            Section {
                HStack {
                    Text("版本")
                    Spacer()
                    Text("1.0")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .formStyle(.grouped)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var defaultMinutesBinding: Binding<Int> {
        Binding(
            get: { settings.defaultMinutes },
            set: { newValue in
                settings.defaultMinutes = newValue
                if timer.canAdjustDuration {
                    settings.sessionMinutes = newValue
                    timer.syncFromSettings()
                }
            }
        )
    }

    private var sessionMinutesBinding: Binding<Int> {
        Binding(
            get: { settings.sessionMinutes },
            set: { timer.setSessionMinutes($0) }
        )
    }
}
