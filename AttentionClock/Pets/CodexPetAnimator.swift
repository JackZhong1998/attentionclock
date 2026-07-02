import Foundation

@MainActor
final class CodexPetAnimator: ObservableObject {
    @Published private(set) var currentClip: PetClip
    @Published private(set) var animationEpoch: Date = .now

    private var pack: CodexPetPack
    private var walkDirection: WalkDirection = .left
    private var pendingResumeClip: PetClip?
    private var completedWalkCycles = 0

    init(pack: CodexPetPack, initialClip: PetClip) {
        self.pack = pack
        currentClip = initialClip
    }

    func replacePack(_ pack: CodexPetPack) {
        self.pack = pack
        animationEpoch = .now
        completedWalkCycles = 0
    }

    func apply(
        timerPhase: TimerPhase,
        expression: CatExpression,
        behavior: CatBehavior,
        pendingReward: Bool,
        mapping: PetActionMapping = .default
    ) {
        let clip = PetStateResolver.resolve(
            timerPhase: timerPhase,
            expression: expression,
            behavior: behavior,
            pendingReward: pendingReward,
            walkDirection: walkDirection,
            pack: pack,
            mapping: mapping
        )

        if clip == currentClip { return }

        if canSwapWithoutRestart(to: clip) {
            currentClip = clip
            return
        }

        start(
            clip: clip,
            timerPhase: timerPhase,
            expression: expression,
            behavior: behavior,
            pendingReward: pendingReward,
            mapping: mapping
        )
    }

    func frameIndex(at date: Date) -> Int {
        let elapsed = max(date.timeIntervalSince(animationEpoch), 0)
        let totalFrames = Int(elapsed * currentClip.fps)

        if currentClip.loop {
            let count = max(currentClip.frameCount, 1)
            return totalFrames % count
        }

        return min(totalFrames, max(currentClip.frameCount - 1, 0))
    }

    func handleTick(at date: Date) {
        let elapsed = max(date.timeIntervalSince(animationEpoch), 0)
        let totalFrames = Int(elapsed * currentClip.fps)

        if currentClip.loop {
            updateWalkDirectionIfNeeded(totalFrames: totalFrames)
            return
        }

        guard totalFrames >= currentClip.frameCount, let resume = pendingResumeClip else { return }
        pendingResumeClip = nil
        completedWalkCycles = 0
        currentClip = resume
        animationEpoch = date
    }

    private func start(
        clip: PetClip,
        timerPhase: TimerPhase,
        expression: CatExpression,
        behavior: CatBehavior,
        pendingReward: Bool,
        mapping: PetActionMapping
    ) {
        pendingResumeClip = nil
        completedWalkCycles = 0
        animationEpoch = .now
        currentClip = clip

        if !clip.loop {
            pendingResumeClip = PetStateResolver.resolve(
                timerPhase: timerPhase,
                expression: expression,
                behavior: behavior,
                pendingReward: false,
                walkDirection: walkDirection,
                pack: pack,
                mapping: mapping
            )
        }
    }

    private func canSwapWithoutRestart(to clip: PetClip) -> Bool {
        guard clip.loop, currentClip.loop else { return false }
        guard clip.fps == currentClip.fps,
              clip.frameCount == currentClip.frameCount,
              clip.row == currentClip.row else { return false }
        return clip.mirror != currentClip.mirror
    }

    private func updateWalkDirectionIfNeeded(totalFrames: Int) {
        guard isWalkClip(currentClip) else { return }

        let count = max(currentClip.frameCount, 1)
        let cycles = totalFrames / count
        guard cycles > completedWalkCycles else { return }
        completedWalkCycles = cycles

        walkDirection = walkDirection == .left ? .right : .left
        let shouldMirror = walkDirection == .left
        guard currentClip.mirror != shouldMirror else { return }

        currentClip = PetClip(
            row: currentClip.row,
            frameCount: currentClip.frameCount,
            fps: currentClip.fps,
            loop: currentClip.loop,
            mirror: shouldMirror
        )
    }

    private func isWalkClip(_ clip: PetClip) -> Bool {
        clip.row == CodexPetRow.runningRight
            || clip.row == CodexPetRow.runningLeft
            || clip.row == CodexPetRow.running
    }
}
