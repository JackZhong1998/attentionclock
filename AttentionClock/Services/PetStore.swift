import Foundation

struct PetCatalogEntry: Identifiable, Equatable {
    let id: String
    let displayName: String
    let description: String
    let isInstalled: Bool
}

struct PetBrowseQuery: Equatable {
    var searchText = ""
    var kindFilter: PetKindFilter = .all
    var franchiseFilter: String? = nil
}

struct PetBrowseSnapshot: Equatable {
    let franchiseOverview: [PetdexFranchiseGroup]
    let sections: [PetBrowseSection]
    let totalMatches: Int
}

@MainActor
final class PetStore: ObservableObject {
    static let pageSize = 48

    @Published private(set) var catalog: [PetCatalogEntry] = []
    @Published private(set) var activePack: CodexPetPack?
    @Published private(set) var activeAtlas: CodexPetAtlas?
    @Published private(set) var remotePets: [PetdexRemotePet] = []
    @Published private(set) var catalogSyncInfo = PetdexCatalogSyncInfo()
    @Published private(set) var catalogError: String?
    @Published var lastSyncResultMessage: String?
    @Published private(set) var importingPetId: String?
    @Published var importError: String?
    @Published private(set) var browseSnapshot = PetBrowseSnapshot(franchiseOverview: [], sections: [], totalMatches: 0)

    @Published var selectedPetId: String? {
        didSet {
            if selectedPetId != oldValue {
                if let selectedPetId {
                    UserDefaults.standard.set(selectedPetId, forKey: Keys.selectedPetId)
                } else {
                    UserDefaults.standard.removeObject(forKey: Keys.selectedPetId)
                }
                reloadActivePack()
            }
        }
    }

    private enum Keys {
        static let selectedPetId = "selectedPetId"
    }

    init() {
        selectedPetId = UserDefaults.standard.string(forKey: Keys.selectedPetId)
        reloadCatalog()
        reloadActivePack()
        remotePets = PetdexCatalogService.loadLocalCatalog()
        catalogSyncInfo = PetdexCatalogService.loadSyncInfo()
        refreshBrowseSnapshot(query: PetBrowseQuery())
    }

    var hasSelectedPet: Bool {
        guard let selectedPetId else { return false }
        return CodexPetPackLoader.isInstalled(id: selectedPetId)
    }

    var installedPetIds: Set<String> {
        Set(CodexPetPackLoader.loadInstalledPacks().map(\.id))
    }

    func installedItems() -> [InstalledPetItem] {
        CodexPetPackLoader.loadInstalledPacks().map { pack in
            InstalledPetItem(
                id: pack.id,
                displayName: pack.displayName,
                spritesheetURL: pack.spritesheetURL,
                isSelected: pack.id == selectedPetId
            )
        }
    }

    func reloadCatalog() {
        catalog = CodexPetPackLoader.loadInstalledPacks().map {
            PetCatalogEntry(
                id: $0.id,
                displayName: $0.displayName,
                description: $0.description,
                isInstalled: true
            )
        }

        if let selectedPetId, !catalog.contains(where: { $0.id == selectedPetId }) {
            self.selectedPetId = nil
        }
    }

    func bootstrapCatalog() async {
        remotePets = PetdexCatalogService.loadLocalCatalog()
        catalogSyncInfo.totalCount = remotePets.count
        refreshBrowseSnapshot(query: PetBrowseQuery())

        if catalogSyncInfo.needsSync {
            await syncCatalog(showResult: false)
        }
    }

    func syncCatalog(showResult: Bool = true) async {
        guard !catalogSyncInfo.isSyncing else { return }

        catalogSyncInfo.isSyncing = true
        catalogError = nil
        lastSyncResultMessage = nil
        defer { catalogSyncInfo.isSyncing = false }

        let knownSlugs = Set(remotePets.map(\.slug))

        do {
            let result = try await PetdexCatalogService.syncCatalog(knownSlugs: knownSlugs)
            remotePets = PetdexCatalogService.loadLocalCatalog()
            catalogSyncInfo.lastSyncedAt = result.syncedAt
            catalogSyncInfo.manifestGeneratedAt = result.manifestGeneratedAt
            catalogSyncInfo.totalCount = result.totalCount
            catalogSyncInfo.lastAddedCount = result.addedCount
            catalogSyncInfo.lastError = nil
            if showResult {
                lastSyncResultMessage = syncSuccessMessage(for: result)
            }
            refreshBrowseSnapshot(query: PetBrowseQuery())
        } catch {
            catalogSyncInfo.lastError = error.localizedDescription
            if remotePets.isEmpty {
                remotePets = PetdexCatalogService.loadLocalCatalog()
            }
            if remotePets.isEmpty {
                catalogError = String(localized: "无法加载宠物图鉴。")
            }
        }
    }

    private func syncSuccessMessage(for result: PetdexCatalogSyncResult) -> String {
        if result.addedCount > 0 {
            return String(localized: "图鉴已更新，新增 \(result.addedCount) 个宠物，共 \(result.totalCount) 个。")
        }
        return String(localized: "图鉴已是最新，共 \(result.totalCount) 个宠物。")
    }

    func refreshBrowseSnapshot(query: PetBrowseQuery) {
        browseSnapshot = Self.buildBrowseSnapshot(
            query: query,
            remotePets: remotePets,
            installedIds: installedPetIds,
            selectedPetId: selectedPetId
        )
    }

    func installAndSelect(_ remote: PetdexRemotePet) async -> Bool {
        importingPetId = remote.slug
        importError = nil
        defer { importingPetId = nil }

        do {
            _ = try await PetdexImporter.install(remote: remote)
            reloadCatalog()
            selectedPetId = remote.slug
            return true
        } catch {
            importError = error.localizedDescription
            return false
        }
    }

    func selectInstalledPet(id: String) {
        guard CodexPetPackLoader.isInstalled(id: id) else { return }
        selectedPetId = id
    }

    nonisolated private static func buildBrowseSnapshot(
        query: PetBrowseQuery,
        remotePets: [PetdexRemotePet],
        installedIds: Set<String>,
        selectedPetId: String?
    ) -> PetBrowseSnapshot {
        let trimmed = query.searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let hasSearch = !trimmed.isEmpty
        let showingAllFranchises = query.franchiseFilter == nil

        let filtered = remotePets.filter { pet in
            guard !installedIds.contains(pet.slug) else { return false }
            guard query.kindFilter.matches(pet.kind) else { return false }
            if let franchiseFilter = query.franchiseFilter, pet.resolvedFranchiseId != franchiseFilter {
                return false
            }
            return pet.matches(query: trimmed)
        }

        if showingAllFranchises && !hasSearch {
            let grouped = Dictionary(grouping: remotePets.filter { pet in
                !installedIds.contains(pet.slug) && query.kindFilter.matches(pet.kind)
            }) { $0.resolvedFranchiseId }

            let overview = PetdexFranchiseCatalog.orderedFranchiseIDs.compactMap { id -> PetdexFranchiseGroup? in
                guard let pets = grouped[id], !pets.isEmpty else { return nil }
                let name = pets.first?.resolvedFranchiseName ?? id
                return PetdexFranchiseGroup(
                    id: id,
                    name: name,
                    count: pets.count,
                    previewSpritesheetURL: pets.first?.spritesheetURL
                )
            }
            return PetBrowseSnapshot(franchiseOverview: overview, sections: [], totalMatches: filtered.count)
        }

        let grouped = Dictionary(grouping: filtered) { $0.resolvedFranchiseId }
        let orderedIDs = PetdexFranchiseCatalog.orderedFranchiseIDs

        var sections: [PetBrowseSection] = []
        for franchiseID in orderedIDs {
            guard let pets = grouped[franchiseID], !pets.isEmpty else { continue }
            let title = pets.first?.resolvedFranchiseName ?? franchiseID
            let items = pets
                .sorted { $0.displayName.localizedCompare($1.displayName) == .orderedAscending }
                .prefix(pageSize)
                .map { pet in
                    PetBrowseItem(
                        id: pet.slug,
                        displayName: pet.displayName,
                        kindLabel: pet.kindLabel,
                        spritesheetURL: pet.spritesheetURL,
                        remotePet: pet,
                        isInstalled: false,
                        isSelected: pet.slug == selectedPetId,
                        franchiseId: franchiseID
                    )
                }
            sections.append(PetBrowseSection(id: franchiseID, title: title, pets: Array(items)))
        }

        return PetBrowseSnapshot(franchiseOverview: [], sections: sections, totalMatches: filtered.count)
    }

    private func reloadActivePack() {
        guard let selectedPetId,
              let pack = CodexPetPackLoader.loadPack(id: selectedPetId) else {
            activePack = nil
            activeAtlas = nil
            return
        }
        activePack = pack
        activeAtlas = CodexPetAtlas(pack: pack)
    }
}
