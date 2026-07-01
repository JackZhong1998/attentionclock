import AppKit
import SwiftUI

struct SpritesheetPetCanvas: NSViewRepresentable {
    let atlas: CodexPetAtlas
    let row: Int
    let frameIndex: Int
    let displayWidth: CGFloat
    let mirror: Bool

    func makeNSView(context: Context) -> SpriteHostView {
        SpriteHostView()
    }

    func updateNSView(_ nsView: SpriteHostView, context: Context) {
        let height = displayWidth * atlas.aspectRatio
        nsView.update(
            image: atlas.nsImage(row: row, column: frameIndex),
            mirror: mirror,
            size: NSSize(width: displayWidth, height: height)
        )
    }
}

final class SpriteHostView: NSView {
    private let imageView = NSImageView()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.backgroundColor = .clear

        imageView.wantsLayer = true
        imageView.imageScaling = .scaleProportionallyUpOrDown
        imageView.imageAlignment = .alignCenter
        imageView.layer?.minificationFilter = .nearest
        imageView.layer?.magnificationFilter = .nearest
        addSubview(imageView)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func layout() {
        super.layout()
        imageView.frame = bounds
    }

    func update(image: NSImage?, mirror: Bool, size: NSSize) {
        frame.size = size
        imageView.frame = NSRect(origin: .zero, size: size)

        if let image, imageView.image !== image {
            imageView.image = image
        }

        imageView.layer?.transform = mirror
            ? CATransform3DMakeScale(-1, 1, 1)
            : CATransform3DIdentity
    }
}
