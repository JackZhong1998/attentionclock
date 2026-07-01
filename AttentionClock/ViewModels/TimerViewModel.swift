import Foundation

enum TimerPhase {
    case idle
    case running
    case paused
}

@MainActor
final class TimerViewModel: ObservableObject {
    @Published private(set) var phase: TimerPhase = .idle
    @Published private(set) var remainingSeconds: Int = 25 * 60
    @Published private(set) var plannedSeconds: Int = 25 * 60

    private var tickTimer: Timer?
    private var sessionStart: Date?
    private var accumulatedSeconds: Int = 0
    private var pauseStarted: Date?

    private let sessionStore: SessionStore
    private let settings: SettingsStore
    private let catStore: CatStore

    init(sessionStore: SessionStore, settings: SettingsStore, catStore: CatStore) {
        self.sessionStore = sessionStore
        self.settings = settings
        self.catStore = catStore
        syncFromSettings()
    }

    var progress: Double {
        guard plannedSeconds > 0 else { return 0 }
        return 1 - Double(remainingSeconds) / Double(plannedSeconds)
    }

    var displayTime: String {
        let m = remainingSeconds / 60
        let s = remainingSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    var canStart: Bool { phase == .idle }
    var canPause: Bool { phase == .running }
    var canResume: Bool { phase == .paused }
    var canEnd: Bool { phase == .running || phase == .paused }
    var canAdjustDuration: Bool { phase == .idle }

    func syncFromSettings() {
        guard phase == .idle else { return }
        plannedSeconds = settings.sessionMinutes * 60
        remainingSeconds = plannedSeconds
    }

    func setSessionMinutes(_ minutes: Int) {
        guard canAdjustDuration else { return }
        settings.sessionMinutes = max(1, min(180, minutes))
        plannedSeconds = settings.sessionMinutes * 60
        remainingSeconds = plannedSeconds
    }

    func start() {
        guard phase == .idle else { return }
        plannedSeconds = settings.sessionMinutes * 60
        remainingSeconds = plannedSeconds
        accumulatedSeconds = 0
        sessionStart = Date()
        phase = .running
        startTicking()
    }

    func pause() {
        guard phase == .running else { return }
        tickTimer?.invalidate()
        tickTimer = nil
        accumulatedSeconds += plannedSeconds - remainingSeconds
        phase = .paused
        pauseStarted = Date()
    }

    func resume() {
        guard phase == .paused else { return }
        phase = .running
        pauseStarted = nil
        startTicking()
    }

    func endSession(reason: SessionEndReason) {
        tickTimer?.invalidate()
        tickTimer = nil

        let elapsed: Int
        switch phase {
        case .idle:
            return
        case .running:
            elapsed = accumulatedSeconds + (plannedSeconds - remainingSeconds)
        case .paused:
            elapsed = accumulatedSeconds
        }

        let record = SessionRecord(
            id: UUID(),
            date: Date(),
            elapsedSeconds: max(elapsed, 0),
            plannedSeconds: plannedSeconds,
            reason: reason
        )
        sessionStore.add(record)

        if settings.desktopPetEnabled {
            catStore.feed(reason: reason, elapsedSeconds: max(elapsed, 0))
            catStore.refreshExpression(timerPhase: .idle)
        }

        if reason == .completed {
            FocusReminderService.shared.notifySessionCompleted(minutes: plannedSeconds / 60)
        }

        phase = .idle
        sessionStart = nil
        accumulatedSeconds = 0
        pauseStarted = nil
        settings.sessionMinutes = settings.defaultMinutes
        syncFromSettings()
    }

    private func startTicking() {
        tickTimer?.invalidate()
        tickTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
        RunLoop.main.add(tickTimer!, forMode: .common)
    }

    private func tick() {
        guard phase == .running, remainingSeconds > 0 else { return }
        remainingSeconds -= 1
        if remainingSeconds == 0 {
            endSession(reason: .completed)
        }
    }
}
