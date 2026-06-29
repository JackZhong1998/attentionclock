import SwiftUI

struct TimerView: View {
    @ObservedObject var timer: TimerViewModel
    @ObservedObject var settings: SettingsStore

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                Circle()
                    .stroke(Color.primary.opacity(0.06), lineWidth: 6)
                    .frame(width: 260, height: 260)

                Circle()
                    .trim(from: 0, to: timer.progress)
                    .stroke(
                        Color.accentColor.opacity(0.85),
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .frame(width: 260, height: 260)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.35), value: timer.progress)

                VStack(spacing: 8) {
                    Text(timer.displayTime)
                        .font(.system(size: 56, weight: .thin, design: .rounded))
                        .monospacedDigit()
                        .contentTransition(.numericText())

                    if timer.canAdjustDuration {
                        durationPicker
                    } else {
                        Text(statusLabel)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.bottom, 48)

            controlButtons
                .padding(.bottom, 32)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var statusLabel: String {
        switch timer.phase {
        case .idle: return "准备开始"
        case .running: return "专注中"
        case .paused: return "已暂停"
        }
    }

    private var durationPicker: some View {
        HStack(spacing: 16) {
            Button {
                timer.setSessionMinutes(settings.sessionMinutes - 5)
            } label: {
                Image(systemName: "minus.circle.fill")
                    .font(.title2)
                    .symbolRenderingMode(.hierarchical)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)

            Text("\(settings.sessionMinutes) 分钟")
                .font(.body)
                .foregroundStyle(.secondary)
                .frame(minWidth: 80)

            Button {
                timer.setSessionMinutes(settings.sessionMinutes + 5)
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .symbolRenderingMode(.hierarchical)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private var controlButtons: some View {
        switch timer.phase {
        case .idle:
            Button(action: timer.start) {
                Label("开始专注", systemImage: "play.fill")
                    .font(.title3.weight(.medium))
                    .frame(width: 200, height: 48)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .keyboardShortcut(.return, modifiers: [])

        case .running:
            HStack(spacing: 20) {
                Button {
                    timer.pause()
                } label: {
                    Label("暂停", systemImage: "pause.fill")
                        .frame(width: 120, height: 44)
                }
                .buttonStyle(.bordered)

                Button(role: .destructive) {
                    timer.endSession(reason: .ended)
                } label: {
                    Label("结束", systemImage: "stop.fill")
                        .frame(width: 120, height: 44)
                }
                .buttonStyle(.bordered)
            }

        case .paused:
            HStack(spacing: 20) {
                Button {
                    timer.resume()
                } label: {
                    Label("继续", systemImage: "play.fill")
                        .frame(width: 120, height: 44)
                }
                .buttonStyle(.borderedProminent)

                Button {
                    timer.endSession(reason: .paused)
                } label: {
                    Label("结束", systemImage: "stop.fill")
                        .frame(width: 120, height: 44)
                }
                .buttonStyle(.bordered)
            }
        }
    }
}
