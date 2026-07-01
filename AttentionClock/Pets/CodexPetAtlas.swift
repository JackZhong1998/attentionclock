import AppKit
import ImageIO

final class CodexPetAtlas {
    let pack: CodexPetPack
    private let cgImage: CGImage
    private var frameCache: [String: CGImage] = [:]
    private var nsImageCache: [String: NSImage] = [:]

    var cellWidth: Int { pack.atlas.cellWidth }
    var cellHeight: Int { pack.atlas.cellHeight }
    var aspectRatio: CGFloat {
        guard cellWidth > 0 else { return 1 }
        return CGFloat(cellHeight) / CGFloat(cellWidth)
    }

    init?(pack: CodexPetPack) {
        self.pack = pack
        guard let source = CGImageSourceCreateWithURL(pack.spritesheetURL as CFURL, nil),
              let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            return nil
        }
        cgImage = image
    }

    func frameImage(row: Int, column: Int) -> CGImage? {
        guard row >= 0, row < pack.atlas.rows,
              column >= 0, column < pack.atlas.columns else {
            return nil
        }

        let key = "\(row)-\(column)"
        if let cached = frameCache[key] {
            return cached
        }

        let y = cgImage.height - (row + 1) * cellHeight
        let rect = CGRect(
            x: column * cellWidth,
            y: y,
            width: cellWidth,
            height: cellHeight
        )

        guard let cropped = cgImage.cropping(to: rect) else { return nil }
        frameCache[key] = cropped
        return cropped
    }

    func nsImage(row: Int, column: Int) -> NSImage? {
        guard let frame = frameImage(row: row, column: column) else { return nil }
        let key = "\(row)-\(column)-ns"
        if let cached = nsImageCache[key] {
            return cached
        }
        let size = NSSize(width: cellWidth, height: cellHeight)
        let image = NSImage(cgImage: frame, size: size)
        nsImageCache[key] = image
        return image
    }
}
