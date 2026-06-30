import SwiftUI

struct PixelCatCanvas: View {
    let frame: CatFrame
    var scale: Int = 4

    private var grid: MCPixelGrid { MCCatSprites.grid(for: frame) }
    private var pixelCount: Int { MCCatSprites.gridSize }

    var body: some View {
        Canvas { context, size in
            let pixelSize = size.width / CGFloat(pixelCount)
            for y in 0..<pixelCount {
                for x in 0..<pixelCount {
                    let pixel = grid[y][x]
                    guard pixel != .empty else { continue }
                    let rect = CGRect(
                        x: CGFloat(x) * pixelSize,
                        y: CGFloat(y) * pixelSize,
                        width: pixelSize,
                        height: pixelSize
                    )
                    context.fill(
                        Path(rect),
                        with: .color(MCPalette.color(for: pixel)),
                        style: FillStyle(eoFill: false, antialiased: false)
                    )
                }
            }
        }
        .frame(
            width: CGFloat(pixelCount * scale),
            height: CGFloat(pixelCount * scale)
        )
    }
}
