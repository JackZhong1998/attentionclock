import Foundation

struct PetdexManifestResponse: Codable {
    let generatedAt: String?
    let total: Int?
    let pets: [PetdexRemotePet]
}

struct PetdexCatalogSyncResult: Equatable {
    let totalCount: Int
    let addedCount: Int
    let updatedCount: Int
    let manifestGeneratedAt: String?
    let syncedAt: Date
}

struct PetdexCatalogSyncInfo: Equatable {
    var lastSyncedAt: Date?
    var manifestGeneratedAt: String?
    var totalCount: Int = 0
    var lastAddedCount: Int = 0
    var isSyncing: Bool = false
    var lastError: String?

    var needsSync: Bool {
        guard let lastSyncedAt else { return true }
        return Date().timeIntervalSince(lastSyncedAt) > PetdexCatalogService.autoSyncInterval
    }
}

enum PetdexCatalogService {
    static let autoSyncInterval: TimeInterval = 60 * 60 * 12

    private static let manifestURL = URL(string: "https://petdex.dev/api/manifest")!

    private struct SyncedCatalog: Codable {
        let syncedAt: Date
        let manifestGeneratedAt: String?
        let pets: [PetdexRemotePet]
    }

    private static var supportDirectoryURL: URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("AttentionClock", isDirectory: true)
        try? FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)
        return base
    }

    private static var syncedCatalogURL: URL {
        supportDirectoryURL.appendingPathComponent("petdex-synced-catalog.json")
    }

    static func loadSyncInfo() -> PetdexCatalogSyncInfo {
        guard let synced = readSyncedCatalog() else {
            let bundled = loadBundledPets()
            return PetdexCatalogSyncInfo(totalCount: bundled.count)
        }
        return PetdexCatalogSyncInfo(
            lastSyncedAt: synced.syncedAt,
            manifestGeneratedAt: synced.manifestGeneratedAt,
            totalCount: synced.pets.count
        )
    }

    static func loadLocalCatalog() -> [PetdexRemotePet] {
        let bundled = loadBundledPets()
        let bundledBySlug = Dictionary(uniqueKeysWithValues: bundled.map { ($0.slug, $0) })

        guard let synced = readSyncedCatalog(), !synced.pets.isEmpty else {
            return bundled
        }

        return merge(remote: synced.pets, bundledBySlug: bundledBySlug)
    }

    static func syncCatalog(knownSlugs: Set<String>) async throws -> PetdexCatalogSyncResult {
        let remoteResponse = try await fetchManifest()
        let bundledBySlug = Dictionary(uniqueKeysWithValues: loadBundledPets().map { ($0.slug, $0) })
        let merged = merge(remote: remoteResponse.pets, bundledBySlug: bundledBySlug)

        let mergedSlugs = Set(merged.map(\.slug))
        let addedCount = mergedSlugs.subtracting(knownSlugs).count
        let updatedCount = remoteResponse.pets.filter { knownSlugs.contains($0.slug) }.count
        let syncedAt = Date()

        let payload = SyncedCatalog(
            syncedAt: syncedAt,
            manifestGeneratedAt: remoteResponse.generatedAt,
            pets: merged
        )
        try writeSyncedCatalog(payload)

        return PetdexCatalogSyncResult(
            totalCount: merged.count,
            addedCount: addedCount,
            updatedCount: updatedCount,
            manifestGeneratedAt: remoteResponse.generatedAt,
            syncedAt: syncedAt
        )
    }

    static func findPet(slug: String, in pets: [PetdexRemotePet]) -> PetdexRemotePet? {
        let normalized = slug.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return pets.first { $0.slug.lowercased() == normalized }
    }

    private static func loadBundledPets() -> [PetdexRemotePet] {
        PetdexIndexLoader.loadBundledIndex().map(PetdexRemotePet.init(entry:))
    }

    private static func merge(remote: [PetdexRemotePet], bundledBySlug: [String: PetdexRemotePet]) -> [PetdexRemotePet] {
        var bySlug = bundledBySlug
        for pet in remote {
            bySlug[pet.slug] = PetdexCatalogEnricher.enrich(pet, preservingMetadataFrom: bySlug[pet.slug])
        }
        return bySlug.values.sorted { $0.displayName.localizedCompare($1.displayName) == .orderedAscending }
    }

    private static func fetchManifest() async throws -> PetdexManifestResponse {
        var request = URLRequest(url: manifestURL)
        request.setValue("AttentionClock/1.0", forHTTPHeaderField: "User-Agent")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw PetdexImportError.networkFailed
        }
        return try JSONDecoder().decode(PetdexManifestResponse.self, from: data)
    }

    private static func readSyncedCatalog() -> SyncedCatalog? {
        guard let data = try? Data(contentsOf: syncedCatalogURL),
              let catalog = try? JSONDecoder().decode(SyncedCatalog.self, from: data) else {
            return nil
        }
        return catalog
    }

    private static func writeSyncedCatalog(_ catalog: SyncedCatalog) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        let data = try encoder.encode(catalog)
        try data.write(to: syncedCatalogURL, options: .atomic)
    }
}
