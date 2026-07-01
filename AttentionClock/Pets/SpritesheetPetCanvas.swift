import SwiftUI

struct SpritesheetPetCanvas: View {
    let atlas: CodexPetAtlas
    let row: Int
    let frameIndex: Int
    let displayWidth: CGFloat
    let mirror: Bool

    var body: some View {
        Canvas { context, size in
            guard let cgImage = atlas.frameImage(row: row, column: frameIndex) else { return }

            var drawContext = context
            if mirror {
                drawContext.translateBy(x: size.width, y: 0)
                drawContext.scaleBy(x: -1, y: 1)
            }

            drawContext.draw(
                Image(decorative: cgImage, scale: 1.0, orientation: .up),
                in: CGRect(origin: .zero, size: size)
            )
        }
        .frame(width: displayWidth, height: displayWidth * atlas.aspectRatio)
    }
}
