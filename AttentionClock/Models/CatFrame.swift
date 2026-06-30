import Foundation

enum CatFrame: String, CaseIterable {
    case frontBase = "front-base"
    case frontEar1 = "front-ear-1"
    case frontEar2 = "front-ear-2"
    case frontBlink = "front-blink"
    case walkLeft1 = "walk-left-1"
    case walkLeft2 = "walk-left-2"
    case walkRight1 = "walk-right-1"
    case walkRight2 = "walk-right-2"
}

enum CatBehavior: Equatable {
    case focusCompanion
    case idleRoaming
}
