import Foundation

enum PetStateResolver {
    static func resolve(
        timerPhase: TimerPhase,
        expression: CatExpression,
        behavior: CatBehavior,
        pendingReward: Bool,
        walkDirection: WalkDirection,
        pack: CodexPetPack
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

        switch timerPhase {
        case .running:
            return .loop(
                row: CodexPetRow.idle,
                frames: pack.frameCount(forRow: CodexPetRow.idle),
                fps: 4
            )
        case .paused:
            return .loop(
                row: CodexPetRow.waiting,
                frames: pack.frameCount(forRow: CodexPetRow.waiting),
                fps: 5
            )
        case .idle:
            if expression == .hungry {
                return .loop(
                    row: CodexPetRow.waiting,
                    frames: pack.frameCount(forRow: CodexPetRow.waiting),
                    fps: 4
                )
            }

            if behavior == .idleRoaming {
                let row = walkDirection == .left ? CodexPetRow.runningLeft : CodexPetRow.runningRight
                return .loop(
                    row: row,
                    frames: pack.frameCount(forRow: row),
                    fps: 8,
                    mirror: false
                )
            }

            return .loop(
                row: CodexPetRow.idle,
                frames: pack.frameCount(forRow: CodexPetRow.idle),
                fps: 6
            )
        }
    }
}
