import SwiftUI

struct TimerView: View {
    @ObservedObject var timer: TimerViewModel
    @ObservedObject var settings: SettingsStore
    @ObservedObject var catStore: CatStore

    private let ringSize: CGFloat = 240

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            timerRingRow
                .padding(.bottom, 36)

            controlButtons
                .padding(.bottom, settings.cloudCatEnabled ? 20 : 32)

            if settings.cloudCatEnabled {
                CatCompanionView(catStore: catStore, timer: timer)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }

            Spacer()
        }
        .animation(.easeInOut(duration: 0.28), value: settings.cloudCatEnabled)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var timerRingRow: some View {
        HStack(alignment: .center, spacing: 20) {
            if timer.canAdjustDuration {
                Button {
                    timer.setSessionMinutes(settings.sessionMinutes - 5)
                } label: {
                    Image(systemName: "minus")
                }
                .buttonStyle(CircleIconButtonStyle())
            } else {
                Color.clear.frame(width: 36, height: 36)
            }

            ZStack {
                Circle()
                    .stroke(Color.primary.opacity(0.07), lineWidth: 5)
                    .frame(width: ringSize, height: ringSize)

                Circle()
                    .trim(from: 0, to: timer.progress)
                    .stroke(
                        Color.primary.opacity(0.28),
                        style: StrokeStyle(lineWidth: 5, lineCap: .round)
                    )
                    .frame(width: ringSize, height: ringSize)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.35), value: timer.progress)

                VStack(spacing: 6) {
                    Text(timer.displayTime)
                        .font(.system(size: 52, weight: .thin, design: .rounded))
                        .monospacedDigit()
                        .contentTransition(.numericText())

                    if !timer.canAdjustDuration {
                        Text(statusLabel)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            if timer.canAdjustDuration {
                Button {
                    timer.setSessionMinutes(settings.sessionMinutes + 5)
                } label: {
                    Image(systemName: "plus")
                }
                .buttonStyle(CircleIconButtonStyle())
            } else {
                Color.clear.frame(width: 36, height: 36)
            }
        }
    }

    private var statusLabel: String {
        switch timer.phase {
        case .idle: return String(localized: "准备开始")
        case .running: return String(localized: "专注中")
        case .paused: return String(localized: "已暂停")
        }
    }

    @ViewBuilder
    private var controlButtons: some View {
        switch timer.phase {
        case .idle:
            Button(action: timer.start) {
                Label("开始专注", systemImage: "play.fill")
                    .frame(width: 200)
            }
            .buttonStyle(SoftButtonStyle(filled: true))
            .keyboardShortcut(.return, modifiers: [])

        case .running:
            HStack(spacing: 16) {
                Button { timer.pause() } label: {
                    Label("暂停", systemImage: "pause.fill")
                        .frame(width: 110)
                }
                .buttonStyle(SoftButtonStyle())

                Button { timer.endSession(reason: .ended) } label: {
                    Label("结束", systemImage: "stop.fill")
                        .frame(width: 110)
                }
                .buttonStyle(SoftButtonStyle())
            }

        case .paused:
            HStack(spacing: 16) {
                Button { timer.resume() } label: {
                    Label("继续", systemImage: "play.fill")
                        .frame(width: 110)
                }
                .buttonStyle(SoftButtonStyle(filled: true))

                Button { timer.endSession(reason: .paused) } label: {
                    Label("结束", systemImage: "stop.fill")
                        .frame(width: 110)
                }
                .buttonStyle(SoftButtonStyle())
            }
        }
    }
}
