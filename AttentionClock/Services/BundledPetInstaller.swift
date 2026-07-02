import Foundation

enum BundledPetCatalog {
    struct Entry {
        let directoryName: String
        let preferredPetID: String
    }

    static let customizeURL = URL(string: "https://x.com/JackZhong1998")!

    static let pets: [Entry] = [
        Entry(directoryName: "kuromi-2", preferredPetID: "kuromi"),
        Entry(directoryName: "capvolt", preferredPetID: "capvolt"),
        Entry(directoryName: "luffy", preferredPetID: "luffy"),
        Entry(directoryName: "yae-miko-kitsune", preferredPetID: "yae-miko-kitsune"),
    ]

    static var defaultPetID: String { pets[0].preferredPetID }
}

enum BundledPetInstaller {
    @discardableResult
    static func installIfNeeded() -> Bool {
        var installedAny = false
        for entry in BundledPetCatalog.pets {
            if installBundledPet(directoryName: entry.directoryName) {
                installedAny = true
            }
        }
        return installedAny
    }

    @discardableResult
    private static func installBundledPet(directoryName: String) -> Bool {
        let destination = CodexPetPackLoader.userPetDirectory(for: directoryName)
        let manifestURL = destination.appendingPathComponent("pet.json")
        guard !FileManager.default.fileExists(atPath: manifestURL.path) else { return false }

        guard let sourceDirectory = bundledPetDirectory(named: directoryName) else { return false }

        do {
            try FileManager.default.createDirectory(
                at: destination.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try FileManager.default.copyItem(at: sourceDirectory, to: destination)
            return CodexPetPackLoader.loadPack(from: destination) != nil
        } catch {
            try? FileManager.default.removeItem(at: destination)
            return false
        }
    }

    private static func bundledPetDirectory(named directoryName: String) -> URL? {
        guard let bundledRoot = Bundle.main.resourceURL?.appendingPathComponent("BundledPets", isDirectory: true) else {
            return nil
        }
        let directory = bundledRoot.appendingPathComponent(directoryName, isDirectory: true)
        let manifest = directory.appendingPathComponent("pet.json")
        guard FileManager.default.fileExists(atPath: manifest.path) else { return nil }
        return directory
    }
}
