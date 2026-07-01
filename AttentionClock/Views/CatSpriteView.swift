import SwiftUI

struct CatSpriteView: View {
    @ObservedObject var petStore: PetStore
    let timerPhase: TimerPhase
    let expression: CatExpression
    let behavior: CatBehavior
    let pendingReward: Bool
    var displayWidth: CGFloat = 80

    var body: some View {
        Group {
            if let atlas = petStore.activeAtlas, let pack = petStore.activePack {
                CodexPetSpriteView(
                    pack: pack,
                    atlas: atlas,
                    timerPhase: timerPhase,
                    expression: expression,
                    behavior: behavior,
                    pendingReward: pendingReward,
                    displayWidth: displayWidth
                )
            } else {
                Color.clear
                    .frame(width: displayWidth, height: displayWidth)
            }
        }
        .transaction { transaction in
            transaction.animation = nil
        }
    }
}

private struct CodexPetSpriteView: View {
    let pack: CodexPetPack
    let atlas: CodexPetAtlas
    let timerPhase: TimerPhase
    let expression: CatExpression
    let behavior: CatBehavior
    let pendingReward: Bool
    let displayWidth: CGFloat

    @StateObject private var animator: CodexPetAnimator

    init(
        pack: CodexPetPack,
        atlas: CodexPetAtlas,
        timerPhase: TimerPhase,
        expression: CatExpression,
        behavior: CatBehavior,
        pendingReward: Bool,
        displayWidth: CGFloat
    ) {
        self.pack = pack
        self.atlas = atlas
        self.timerPhase = timerPhase
        self.expression = expression
        self.behavior = behavior
        self.pendingReward = pendingReward
        self.displayWidth = displayWidth

        let initialClip = PetStateResolver.resolve(
            timerPhase: timerPhase,
            expression: expression,
            behavior: behavior,
            pendingReward: pendingReward,
            walkDirection: .left,
            pack: pack
        )
        _animator = StateObject(wrappedValue: CodexPetAnimator(pack: pack, initialClip: initialClip))
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / max(animator.currentClip.fps, 1))) { context in
            let frameIndex = animator.frameIndex(at: context.date)

            SpritesheetPetCanvas(
                atlas: atlas,
                row: animator.currentClip.row,
                frameIndex: frameIndex,
                displayWidth: displayWidth,
                mirror: animator.currentClip.mirror
            )
            .background {
                PetAnimationTick(animator: animator, date: context.date)
            }
        }
        .onAppear { syncAnimator() }
        .onChange(of: pack.id) { _, _ in
            animator.replacePack(pack)
            syncAnimator()
        }
        .onChange(of: timerPhase) { _, _ in syncAnimator() }
        .onChange(of: expression) { _, _ in syncAnimator() }
        .onChange(of: behavior) { _, _ in syncAnimator() }
        .onChange(of: pendingReward) { _, _ in syncAnimator() }
    }

    private func syncAnimator() {
        animator.apply(
            timerPhase: timerPhase,
            expression: expression,
            behavior: behavior,
            pendingReward: pendingReward
        )
    }
}

private struct PetAnimationTick: View {
    @ObservedObject var animator: CodexPetAnimator
    let date: Date

    private var tickKey: Int {
        Int(date.timeIntervalSinceReferenceDate * max(animator.currentClip.fps, 1))
    }

    var body: some View {
        Color.clear
            .frame(width: 0, height: 0)
            .onAppear { animator.handleTick(at: date) }
            .onChange(of: tickKey) { _, _ in animator.handleTick(at: date) }
    }
}
