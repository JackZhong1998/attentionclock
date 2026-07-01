import SwiftUI

struct FloatingCatView: View {
    @ObservedObject var petStore: PetStore
    @ObservedObject var catStore: CatStore
    @ObservedObject var timer: TimerViewModel

    @State private var isHovering = false

    private var spriteWidth: CGFloat { 88 }

    private var spriteHeight: CGFloat {
        spriteWidth * (petStore.activeAtlas?.aspectRatio ?? 1.08)
    }

    var body: some View {
        VStack(spacing: 6) {
            ZStack(alignment: .top) {
                if catStore.pendingRewardNotice {
                    Text("猫粮 +1")
                        .font(.system(size: 10, weight: .semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(Color.white.opacity(0.95)))
                        .overlay(Capsule().stroke(Color.primary.opacity(0.12), lineWidth: 1))
                        .offset(y: -6)
                }

                CatSpriteView(
                    petStore: petStore,
                    timerPhase: timer.phase,
                    expression: catStore.expression,
                    behavior: behavior,
                    pendingReward: catStore.pendingRewardNotice,
                    displayWidth: spriteWidth
                )
            }
            .frame(height: max(spriteHeight, 88))
            .contentShape(Rectangle())
            .onTapGesture { handlePrimaryTap() }

            if isHovering {
                actionBar
            } else {
                Color.clear.frame(height: 32)
            }
        }
        .frame(width: 152, height: max(spriteHeight, 88) + 38)
        .onHover { isHovering = $0 }
        .onAppear { catStore.refreshExpression(timerPhase: timer.phase) }
        .onChange(of: timer.phase) { _, phase in catStore.refreshExpression(timerPhase: phase) }
    }

    @ViewBuilder
    private var actionBar: some View {
        HStack(spacing: 8) {
            if timer.canStart {
                actionButton(String(localized: "开始")) { timer.start() }
            } else if timer.phase == .running {
                actionButton(String(localized: "暂停")) { timer.pause() }
                actionButton(String(localized: "结束")) { timer.endSession(reason: .ended) }
            } else if timer.canResume {
                actionButton(String(localized: "继续")) { timer.resume() }
                actionButton(String(localized: "结束")) { timer.endSession(reason: .paused) }
            } else if catStore.pendingRewardNotice {
                actionButton(String(localized: "知道了")) { catStore.acknowledgeReward() }
            }
        }
        .frame(height: 32)
    }

    private func actionButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.white.opacity(0.95))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(Color.primary.opacity(0.12), lineWidth: 1)
        )
    }

    private var behavior: CatBehavior {
        switch timer.phase {
        case .running, .paused: return .focusCompanion
        case .idle: return .idleRoaming
        }
    }

    private func handlePrimaryTap() {
        if catStore.pendingRewardNotice {
            catStore.acknowledgeReward()
        } else if timer.canStart {
            timer.start()
        }
    }
}
