import Foundation

enum PetStateResolver {
    static func resolve(
        timerPhase: TimerPhase,
        expression: CatExpression,
        behavior: CatBehavior,
        pendingReward: Bool,
        walkDirection: WalkDirection,
        pack: CodexPetPack,
        mapping: PetActionMapping = .default
    ) -> PetClip {
        if pendingReward {
            return .oneShot(
                row: CodexPetRow.waving,
                frames: pack.frameCount(forRow: CodexPetRow.waving),
                fps: 10
            )
        }

        if expression == .celebrating {
            return .loop(
                row: CodexPetRow.jumping,
                frames: pack.frameCount(forRow: CodexPetRow.jumping),
                fps: 8
            )
        }

        let row: Int
        switch timerPhase {
        case .running:
            row = mapping.focusRow
        case .paused:
            row = mapping.pausedRow
        case .idle:
            row = mapping.idleRow
        }

        return .loop(
            row: row,
            frames: pack.frameCount(forRow: row),
            fps: PetActionCatalog.defaultFPS(for: row)
        )
    }
}
