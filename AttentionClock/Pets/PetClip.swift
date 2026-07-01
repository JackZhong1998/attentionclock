import Foundation

enum WalkDirection: Equatable {
    case left
    case right
}

struct PetClip: Equatable {
    let row: Int
    let frameCount: Int
    let fps: Double
    let loop: Bool
    let mirror: Bool

    static func loop(row: Int, frames: Int, fps: Double = 6, mirror: Bool = false) -> PetClip {
        PetClip(row: row, frameCount: max(frames, 1), fps: fps, loop: true, mirror: mirror)
    }

    static func oneShot(row: Int, frames: Int, fps: Double = 10, mirror: Bool = false) -> PetClip {
        PetClip(row: row, frameCount: max(frames, 1), fps: fps, loop: false, mirror: mirror)
    }
}

enum CodexPetRow {
    static let idle = 0
    static let runningRight = 1
    static let runningLeft = 2
    static let waving = 3
    static let jumping = 4
    static let failed = 5
    static let waiting = 6
    static let running = 7
    static let review = 8

    static let standardFrameCounts = [6, 8, 8, 4, 5, 8, 6, 6, 6]

    static func defaultFrameCount(for row: Int) -> Int {
        guard row >= 0, row < standardFrameCounts.count else { return 6 }
        return standardFrameCounts[row]
    }
}
