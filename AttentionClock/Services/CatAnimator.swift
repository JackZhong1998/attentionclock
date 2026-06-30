import Foundation

@MainActor
final class CatAnimator: ObservableObject {
    @Published private(set) var currentFrame: CatFrame = .frontBase

    private var behavior: CatBehavior = .idleRoaming
    private var timers: [Timer] = []
    private var walkDirection: Int = -1
    private var walkTicks = 0

    func apply(behavior: CatBehavior) {
        guard self.behavior != behavior else { return }
        self.behavior = behavior
        stopAll()
        currentFrame = .frontBase

        switch behavior {
        case .focusCompanion:
            scheduleFocusLoops()
        case .idleRoaming:
            startIdleWalk(direction: -1)
        }
    }

    func refreshIfNeeded(behavior: CatBehavior) {
        if self.behavior != behavior {
            apply(behavior: behavior)
        }
    }

    private func setFrame(_ frame: CatFrame) {
        currentFrame = frame
    }

    private func scheduleFocusLoops() {
        scheduleEarTwitch()
        scheduleBlink()
    }

    private func scheduleEarTwitch() {
        let delay = Double.random(in: 3.2...5.5)
        let timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            Task { @MainActor in
                guard let self, self.behavior == .focusCompanion else { return }
                self.playEarTwitch()
                self.scheduleEarTwitch()
            }
        }
        timers.append(timer)
    }

    private func scheduleBlink() {
        let delay = Double.random(in: 4.5...8.0)
        let timer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            Task { @MainActor in
                guard let self, self.behavior == .focusCompanion else { return }
                self.playBlink()
                self.scheduleBlink()
            }
        }
        timers.append(timer)
    }

    private func playEarTwitch() {
        setFrame(.frontEar1)
        after(0.14) { [weak self] in self?.setFrame(.frontEar2) }
        after(0.28) { [weak self] in self?.setFrame(.frontBase) }
    }

    private func playBlink() {
        setFrame(.frontBlink)
        after(0.12) { [weak self] in self?.setFrame(.frontBase) }
    }

    private func startIdleWalk(direction: Int) {
        walkDirection = direction
        walkTicks = 0
        stepWalk()
    }

    private func stepWalk() {
        guard behavior == .idleRoaming else { return }

        let frame: CatFrame
        if walkDirection < 0 {
            frame = walkTicks % 2 == 0 ? .walkLeft1 : .walkLeft2
        } else {
            frame = walkTicks % 2 == 0 ? .walkRight1 : .walkRight2
        }
        setFrame(frame)
        walkTicks += 1

        if walkTicks >= 8 {
            pauseThenTurn()
            return
        }

        let timer = Timer.scheduledTimer(withTimeInterval: 0.26, repeats: false) { [weak self] _ in
            Task { @MainActor in self?.stepWalk() }
        }
        timers.append(timer)
    }

    private func pauseThenTurn() {
        setFrame(.frontBase)
        after(0.55) { [weak self] in
            guard let self, self.behavior == .idleRoaming else { return }
            self.playBlink()
        }
        after(1.0) { [weak self] in
            guard let self, self.behavior == .idleRoaming else { return }
            self.startIdleWalk(direction: self.walkDirection * -1)
        }
    }

    private func after(_ interval: TimeInterval, action: @escaping @MainActor () -> Void) {
        let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { _ in
            Task { @MainActor in action() }
        }
        timers.append(timer)
    }

    private func stopAll() {
        timers.forEach { $0.invalidate() }
        timers.removeAll()
    }

    deinit {
        timers.forEach { $0.invalidate() }
    }
}
