import Foundation

enum PetdexImportError: LocalizedError {
    case networkFailed
    case invalidPackage
    case alreadyInstalled

    var errorDescription: String? {
        switch self {
        case .networkFailed:
            return String(localized: "网络连接失败，请稍后重试。")
        case .invalidPackage:
            return String(localized: "伙伴包格式无效，无法安装。")
        case .alreadyInstalled:
            return String(localized: "该伙伴已下载。")
        }
    }
}

enum PetdexImporter {
    static func install(remote: PetdexRemotePet) async throws -> CodexPetPack {
        let directory = CodexPetPackLoader.userPetDirectory(for: remote.slug)
        if FileManager.default.fileExists(atPath: directory.appendingPathComponent("pet.json").path) {
            if let existing = CodexPetPackLoader.loadPack(from: directory) {
                return existing
            }
        }

        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        guard let petJsonURL = remote.petJsonURL,
              let spritesheetURL = remote.spritesheetURL else {
            throw PetdexImportError.invalidPackage
        }

        let petJSONData = try await download(petJsonURL)
        let spritesheetData = try await download(spritesheetURL)

        let manifestURL = directory.appendingPathComponent("pet.json")
        let spritesheetFileURL = directory.appendingPathComponent("spritesheet.webp")
        try petJSONData.write(to: manifestURL, options: .atomic)
        try spritesheetData.write(to: spritesheetFileURL, options: .atomic)

        guard let pack = CodexPetPackLoader.loadPack(from: directory) else {
            try? FileManager.default.removeItem(at: directory)
            throw PetdexImportError.invalidPackage
        }
        return pack
    }

    private static func download(_ url: URL) async throws -> Data {
        var request = URLRequest(url: url)
        request.setValue("AttentionClock/1.0", forHTTPHeaderField: "User-Agent")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw PetdexImportError.networkFailed
        }
        return data
    }
}
