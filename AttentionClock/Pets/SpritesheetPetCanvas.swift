import SwiftUI

struct SpritesheetPetCanvas: View {
    let atlas: CodexPetAtlas
    let row: Int
    let frameIndex: Int
    let displayWidth: CGFloat
    let mirror: Bool

    var body: some View {
        Group {
            if let image = atlas.nsImage(row: row, column: frameIndex) {
                Image(nsImage: image)
                    .interpolation(.none)
                    .resizable()
                    .aspectRatio(atlas.aspectRatio, contentMode: .fit)
                    .scaleEffect(x: mirror ? -1 : 1, y: 1)
            } else {
                Color.clear
            }
        }
        .frame(width: displayWidth, height: displayWidth * atlas.aspectRatio)
    }
}
