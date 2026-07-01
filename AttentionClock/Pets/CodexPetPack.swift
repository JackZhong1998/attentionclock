import Foundation
import ImageIO

struct CodexPetPack: Identifiable, Equatable {
    let id: String
    let displayName: String
    let description: String
    let directoryURL: URL
    let spritesheetURL: URL
    let atlas: CodexPetAtlasSpec
    let stateSpecs: [CodexPetStateSpec]
    let source: PetPackSource

    func frameCount(forRow row: Int) -> Int {
        if let state = stateSpecs.first(where: { $0.row == row }) {
            return max(state.frames, 1)
        }
        return CodexPetRow.defaultFrameCount(for: row)
    }
}

enum PetPackSource: Equatable {
    case downloaded
}

enum CodexPetPackLoader {
    static func loadInstalledPacks() -> [CodexPetPack] {
        guard let userRoot = userPetsRootURL(),
              let entries = try? FileManager.default.contentsOfDirectory(
                at: userRoot,
                includingPropertiesForKeys: [.isDirectoryKey],
                options: [.skipsHiddenFiles]
              ) else { return [] }

        return entries
            .compactMap { loadPack(from: $0) }
            .sorted { $0.displayName.localizedCompare($1.displayName) == .orderedAscending }
    }

    static func loadPack(id: String) -> CodexPetPack? {
        loadInstalledPacks().first { $0.id == id }
    }

    static func isInstalled(id: String) -> Bool {
        loadPack(id: id) != nil
    }

    static func userPetsRootURL() -> URL? {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?
            .appendingPathComponent("AttentionClock", isDirectory: true)
            .appendingPathComponent("pets", isDirectory: true)
        if let base {
            try? FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)
        }
        return base
    }

    static func userPetDirectory(for id: String) -> URL {
        userPetsRootURL()!.appendingPathComponent(id, isDirectory: true)
    }

    static func loadPack(from directory: URL) -> CodexPetPack? {
        let manifestURL = directory.appendingPathComponent("pet.json")
        guard FileManager.default.fileExists(atPath: manifestURL.path),
              let data = try? Data(contentsOf: manifestURL),
              let manifest = try? JSONDecoder().decode(CodexPetManifest.self, from: data) else {
            return nil
        }

        let spritesheetURL = directory.appendingPathComponent(manifest.resolvedSpritesheetName)
        guard FileManager.default.fileExists(atPath: spritesheetURL.path),
              let imageSize = imagePixelSize(at: spritesheetURL) else {
            return nil
        }

        return CodexPetPack(
            id: manifest.resolvedId,
            displayName: manifest.resolvedDisplayName,
            description: manifest.description ?? "",
            directoryURL: directory,
            spritesheetURL: spritesheetURL,
            atlas: manifest.atlasSpec(imageWidth: imageSize.width, imageHeight: imageSize.height),
            stateSpecs: manifest.stateSpecs,
            source: .downloaded
        )
    }

    private static func imagePixelSize(at url: URL) -> (width: Int, height: Int)? {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
              let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
              let width = properties[kCGImagePropertyPixelWidth] as? Int,
              let height = properties[kCGImagePropertyPixelHeight] as? Int else {
            return nil
        }
        return (width, height)
    }
}
