import SwiftUI

struct CatSpriteView: View {
    let behavior: CatBehavior
    var scale: Int = 4

    @StateObject private var animator = CatAnimator()

    var body: some View {
        PixelCatCanvas(frame: animator.currentFrame, scale: scale)
            .transaction { transaction in
                transaction.animation = nil
            }
            .onAppear {
                animator.apply(behavior: behavior)
            }
            .onChange(of: behavior) { _, newValue in
                animator.apply(behavior: newValue)
            }
    }
}
