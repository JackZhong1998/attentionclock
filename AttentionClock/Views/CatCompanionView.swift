import SwiftUI

struct CatCompanionView: View {
    @ObservedObject var catStore: CatStore
    @ObservedObject var timer: TimerViewModel

    var body: some View {
        VStack(spacing: 6) {
            CatSpriteView(behavior: behavior, scale: 5)

            Text(catStore.state.name)
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
}
