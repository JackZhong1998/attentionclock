import SwiftUI

struct CatCompanionView: View {
    @ObservedObject var petStore: PetStore
    @ObservedObject var catStore: CatStore
    @ObservedObject var timer: TimerViewModel

    var body: some View {
        VStack(spacing: 6) {
            PetStatusBubble(text: catStore.companionBubbleLabel(timerPhase: timer.phase))

            CatSpriteView(
                petStore: petStore,
                timerPhase: timer.phase,
                expression: catStore.expression,
                behavior: behavior,
                pendingReward: catStore.pendingRewardNotice,
                displayWidth: spriteWidth
            )
            .frame(width: spriteWidth, height: spriteHeight, alignment: .center)
            .frame(maxWidth: .infinity)

            Text(selectedPetName)
                .font(.caption.weight(.medium))
                .foregroundStyle(.primary.opacity(0.75))
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 6)
        .onAppear { catStore.refreshExpression(timerPhase: timer.phase) }
        .onChange(of: timer.phase) { _, phase in catStore.refreshExpression(timerPhase: phase) }
    }

    private var behavior: CatBehavior {
        switch timer.phase {
        case .running, .paused: return .focusCompanion
        case .idle: return .idleRoaming
        }
    }

    private var spriteWidth: CGFloat { 88 }

    private var spriteHeight: CGFloat {
        spriteWidth * (petStore.activeAtlas?.aspectRatio ?? 1.08)
    }

    private var selectedPetName: String {
        petStore.activePack?.displayName
            ?? petStore.installedItems().first(where: \.isSelected)?.displayName
            ?? ""
    }
}
