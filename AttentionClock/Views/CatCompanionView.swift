import SwiftUI

struct CatCompanionView: View {
    @ObservedObject var petStore: PetStore
    @ObservedObject var catStore: CatStore
    @ObservedObject var timer: TimerViewModel

    var body: some View {
        VStack(spacing: 6) {
            CatSpriteView(
                petStore: petStore,
                timerPhase: timer.phase,
                expression: catStore.expression,
                behavior: behavior,
                pendingReward: catStore.pendingRewardNotice,
                displayWidth: spriteWidth
            )

            Text(selectedPetName)
                .font(.caption.weight(.medium))
                .foregroundStyle(.primary.opacity(0.75))

            Text(catStore.shortStatus)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
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

    private var selectedPetName: String {
        petStore.activePack?.displayName
            ?? petStore.installedItems().first(where: \.isSelected)?.displayName
            ?? ""
    }
}
