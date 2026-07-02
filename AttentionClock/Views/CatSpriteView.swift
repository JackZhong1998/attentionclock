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
                    petStore: petStore,
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
    @ObservedObject var petStore: PetStore
    let pack: CodexPetPack
    let atlas: CodexPetAtlas
    let timerPhase: TimerPhase
    let expression: CatExpression
    let behavior: CatBehavior
    let pendingReward: Bool
    let displayWidth: CGFloat

    @StateObject private var animator: CodexPetAnimator

    private var mapping: PetActionMapping {
        petStore.actionMapping(for: pack.id)
    }

    init(
        petStore: PetStore,
        pack: CodexPetPack,
        atlas: CodexPetAtlas,
        timerPhase: TimerPhase,
        expression: CatExpression,
        behavior: CatBehavior,
        pendingReward: Bool,
        displayWidth: CGFloat
    ) {
        self.petStore = petStore
        self.pack = pack
        self.atlas = atlas
        self.timerPhase = timerPhase
        self.expression = expression
        self.behavior = behavior
        self.pendingReward = pendingReward
        self.displayWidth = displayWidth

        let initialMapping = petStore.actionMapping(for: pack.id)
        let initialClip = PetStateResolver.resolve(
            timerPhase: timerPhase,
            expression: expression,
            behavior: behavior,
            pendingReward: pendingReward,
            walkDirection: .left,
            pack: pack,
            mapping: initialMapping
        )
        _animator = StateObject(wrappedValue: CodexPetAnimator(pack: pack, initialClip: initialClip))
    }

    var body: some View {
        TimelineView(
            .periodic(
                from: animator.animationEpoch,
                by: 1.0 / max(animator.currentClip.fps, 1)
            )
        ) { context in
            PetAnimationFrame(
                animator: animator,
                atlas: atlas,
                displayWidth: displayWidth,
                date: context.date
            )
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
        .onChange(of: petStore.actionMappingRevision) { _, _ in syncAnimator() }
    }

    private func syncAnimator() {
        animator.apply(
            timerPhase: timerPhase,
            expression: expression,
            behavior: behavior,
            pendingReward: pendingReward,
            mapping: mapping
        )
    }
}

private struct PetAnimationFrame: View {
    @ObservedObject var animator: CodexPetAnimator
    let atlas: CodexPetAtlas
    let displayWidth: CGFloat
    let date: Date

    private var tickKey: Int {
        Int(date.timeIntervalSinceReferenceDate * max(animator.currentClip.fps, 1))
    }

    var body: some View {
        SpritesheetPetCanvas(
            atlas: atlas,
            row: animator.currentClip.row,
            frameIndex: animator.frameIndex(at: date),
            displayWidth: displayWidth,
            mirror: animator.currentClip.mirror
        )
        .onChange(of: tickKey, initial: true) { _, _ in
            animator.handleTick(at: date)
        }
    }
}
