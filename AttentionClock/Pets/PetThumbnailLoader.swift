import AppKit
import CryptoKit
import Foundation
import ImageIO

enum PetThumbnailLoader {
    private static let memoryCache: NSCache<NSURL, NSImage> = {
        let cache = NSCache<NSURL, NSImage>()
        cache.countLimit = 256
        return cache
    }()

    private static let diskDirectory: URL = {
        let base = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        return base.appendingPathComponent("PetThumbnails", isDirectory: true)
    }()

    private static let loader = LoaderActor()

    static func cachedThumbnail(for url: URL) -> NSImage? {
        if let cached = memoryCache.object(forKey: url as NSURL) {
            return cached
        }
        if let disk = loadFromDisk(url: url) {
            memoryCache.setObject(disk, forKey: url as NSURL)
            return disk
        }
        return nil
    }

    static func thumbnail(for url: URL) async -> NSImage? {
        if let cached = cachedThumbnail(for: url) {
            return cached
        }
        return await loader.thumbnail(for: url)
    }

    private static func store(_ image: NSImage, for url: URL) {
        memoryCache.setObject(image, forKey: url as NSURL)
        guard !url.isFileURL else { return }
        saveToDisk(image: image, url: url)
    }

    private static func cacheFileURL(for source: URL) -> URL {
        let digest = SHA256.hash(data: Data(source.absoluteString.utf8))
        let name = digest.map { String(format: "%02x", $0) }.joined() + ".png"
        return diskDirectory.appendingPathComponent(name)
    }

    private static func loadFromDisk(url: URL) -> NSImage? {
        let fileURL = cacheFileURL(for: url)
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
        return NSImage(contentsOf: fileURL)
    }

    private static func saveToDisk(image: NSImage, url: URL) {
        guard let tiff = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiff),
              let png = bitmap.representation(using: .png, properties: [:]) else {
            return
        }

        do {
            try FileManager.default.createDirectory(at: diskDirectory, withIntermediateDirectories: true)
            try png.write(to: cacheFileURL(for: url))
        } catch {
            // Best-effort cache; ignore write failures.
        }
    }

    private static func cropFirstFrame(from cgImage: CGImage) -> NSImage? {
        let columns = 8
        let rows = 9
        let cellW = cgImage.width / columns
        let cellH = cgImage.height / rows
        let y = cgImage.height - cellH
        let rect = CGRect(x: 0, y: y, width: cellW, height: cellH)
        guard let cropped = cgImage.cropping(to: rect) else { return nil }
        return NSImage(cgImage: cropped, size: NSSize(width: cellW, height: cellH))
    }

    private static func loadLocalThumbnail(url: URL) -> NSImage? {
        let directory = url.deletingLastPathComponent()
        guard let pack = CodexPetPackLoader.loadPack(from: directory) else { return nil }
        return CodexPetAtlas(pack: pack)?.nsImage(row: 0, column: 0)
    }

    private static func loadRemoteThumbnail(url: URL) async -> NSImage? {
        var request = URLRequest(url: url)
        request.setValue("AttentionClock/1.0", forHTTPHeaderField: "User-Agent")
        guard let (data, response) = try? await URLSession.shared.data(for: request),
              let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode),
              let source = CGImageSourceCreateWithData(data as CFData, nil),
              let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            return nil
        }
        return cropFirstFrame(from: cgImage)
    }

    private actor LoaderActor {
        private var inflight: [URL: Task<NSImage?, Never>] = [:]

        func thumbnail(for url: URL) async -> NSImage? {
            if let existing = inflight[url] {
                return await existing.value
            }

            let task = Task<NSImage?, Never> {
                if url.isFileURL {
                    return PetThumbnailLoader.loadLocalThumbnail(url: url)
                }
                return await PetThumbnailLoader.loadRemoteThumbnail(url: url)
            }
            inflight[url] = task
            defer { inflight[url] = nil }

            guard let image = await task.value else { return nil }
            PetThumbnailLoader.store(image, for: url)
            return image
        }
    }
}
