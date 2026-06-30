import Foundation

@MainActor
final class CatStore: ObservableObject {
    @Published private(set) var state: CatState = .initial
    @Published var expression: CatExpression = .waiting
    @Published var bubbleMessage: String = CatExpression.waiting.message
    @Published var pendingRewardNotice = false

    var shortStatus: String {
        if pendingRewardNotice { return String(localized: "专注完成，猫粮已领取") }
        switch expression {
        case .happy: return String(localized: "状态不错")
        case .sleepy: return String(localized: "陪伴中")
        case .hungry: return String(localized: "等你回来")
        case .waiting: return String(localized: "等你开始")
        case .celebrating: return String(localized: "好开心")
        }
    }

    private let fileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("AttentionClock", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("cat.json")
        load()
        applyDailyDecayIfNeeded()
        refreshExpression(timerPhase: .idle)
    }

    func feed(reason: SessionEndReason, elapsedSeconds: Int) {
        let bonus: (hunger: Int, mood: Int, affection: Int, fed: Int) = switch reason {
        case .completed: (12, 12, 8, 1)
        case .paused: (6, 4, 3, 0)
        case .ended: (3, 2, 1, 0)
        }

        state.hunger = min(100, state.hunger + bonus.hunger)
        state.mood = min(100, state.mood + bonus.mood)
        state.affection = min(100, state.affection + bonus.affection)
        state.totalFedCount += bonus.fed
        state.lastInteractionDate = Date()

        if state.totalFedCount >= 10, state.stage == .kitten {
            state.stage = .adult
        }

        let minutes = max(elapsedSeconds / 60, 1)
        if reason == .completed {
            expression = .celebrating
            bubbleMessage = L10n.catFedMinutes(minutes)
            pendingRewardNotice = true
        } else {
            expression = .happy
            bubbleMessage = String(localized: "虽然没完成，但也陪了我一会儿～")
        }

        save()
    }

    func acknowledgeReward() {
        pendingRewardNotice = false
        expression = .happy
        refreshExpression(timerPhase: .idle)
    }

    func refreshExpression(timerPhase: TimerPhase) {
        applyDailyDecayIfNeeded()

        if pendingRewardNotice { return }

        switch timerPhase {
        case .running:
            expression = .sleepy
            bubbleMessage = String(localized: "安静地趴在你旁边…")
        case .paused:
            expression = .waiting
            bubbleMessage = String(localized: "怎么停下来了？")
        case .idle:
            if state.hunger < 35 || state.mood < 35 {
                expression = .hungry
                bubbleMessage = CatExpression.hungry.message
            } else if state.mood >= 70 {
                expression = .happy
                bubbleMessage = CatExpression.happy.message
            } else {
                expression = .waiting
                bubbleMessage = CatExpression.waiting.message
            }
        }
    }

    func applyDailyDecayIfNeeded() {
        guard let last = state.lastInteractionDate else { return }
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: last), to: calendar.startOfDay(for: Date())).day ?? 0
        guard days > 0 else { return }

        let decay = min(days * 8, 40)
        state.hunger = max(20, state.hunger - decay)
        state.mood = max(20, state.mood - decay)
        save()
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode(CatState.self, from: data) else { return }
        state = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(state) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
