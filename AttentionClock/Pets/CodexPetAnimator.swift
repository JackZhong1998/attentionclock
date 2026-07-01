import Foundation

@MainActor
final class CodexPetAnimator: ObservableObject {
    @Published private(set) var currentFrameIndex = 0
    @Published private(set) var currentClip: PetClip
    @Published private(set) var walkDirection: WalkDirection = .left

    private var timers: [Timer] = []
    private var pack: CodexPetPack
    private var pendingResumeClip: PetClip?

    init(pack: CodexPetPack, initialClip: PetClip) {
        self.pack = pack
        currentClip = initialClip
    }

    func replacePack(_ pack: CodexPetPack) {
        self.pack = pack
        stopAll()
        currentFrameIndex = 0
    }

    func apply(
        timerPhase: TimerPhase,
        expression: CatExpression,
        behavior: CatBehavior,
        pendingReward: Bool
    ) {
        let clip = PetStateResolver.resolve(
            timerPhase: timerPhase,
            expression: expression,
            behavior: behavior,
            pendingReward: pendingReward,
            walkDirection: walkDirection,
            pack: pack
        )

        guard clip != currentClip || timers.isEmpty else { return }
        start(clip: clip, timerPhase: timerPhase, expression: expression, behavior: behavior, pendingReward: pendingReward)
    }

    private func start(
        clip: PetClip,
        timerPhase: TimerPhase,
        expression: CatExpression,
        behavior: CatBehavior,
        pendingReward: Bool
    ) {
        stopAll()
        currentClip = clip
        currentFrameIndex = 0
        pendingResumeClip = nil

        if !clip.loop {
            pendingResumeClip = PetStateResolver.resolve(
                timerPhase: timerPhase,
                expression: expression,
                behavior: behavior,
                pendingReward: false,
                walkDirection: walkDirection,
                pack: pack
            )
        }

        scheduleNextTick()
    }

    private func scheduleNextTick() {
        let interval = 1.0 / max(currentClip.fps, 1)
        let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            Task { @MainActor in self?.advanceFrame() }
        }
        timers.append(timer)
    }

    private func advanceFrame() {
        let nextIndex = currentFrameIndex + 1

        if nextIndex >= currentClip.frameCount {
            if currentClip.loop {
                if currentClip.row == CodexPetRow.runningLeft || currentClip.row == CodexPetRow.runningRight {
                    if nextIndex >= 8 {
                        walkDirection = walkDirection == .left ? .right : .left
                    }
                }
                currentFrameIndex = 0
                scheduleNextTick()
                return
            }

            if let resume = pendingResumeClip {
                pendingResumeClip = nil
                currentClip = resume
                currentFrameIndex = 0
                scheduleNextTick()
                return
            }

            currentFrameIndex = max(currentClip.frameCount - 1, 0)
            return
        }

        currentFrameIndex = nextIndex
        scheduleNextTick()
    }

    private func stopAll() {
        timers.forEach { $0.invalidate() }
        timers.removeAll()
    }

    deinit {
        timers.forEach { $0.invalidate() }
    }
}
