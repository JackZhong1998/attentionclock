import Foundation

struct PetdexRemotePet: Identifiable, Codable, Equatable {
    let slug: String
    let displayName: String
    let kind: String
    let submittedBy: String?
    let spritesheetUrl: String
    let petJsonUrl: String
    let zipUrl: String
    let franchiseId: String?
    let franchiseName: String?
    let searchTerms: [String]?

    var id: String { slug }

    var spritesheetURL: URL? { URL(string: spritesheetUrl) }
    var petJsonURL: URL? { URL(string: petJsonUrl) }
    var zipURL: URL? { URL(string: zipUrl) }

    var resolvedFranchiseId: String {
        franchiseId ?? PetdexFranchiseCatalog.franchise(for: slug, displayName: displayName, kind: kind).id
    }

    var resolvedFranchiseName: String {
        franchiseName ?? PetdexFranchiseCatalog.franchise(for: slug, displayName: displayName, kind: kind).name
    }

    var kindLabel: String {
        switch kind.lowercased() {
        case "character": return String(localized: "角色")
        case "creature": return String(localized: "生物")
        case "object": return String(localized: "物件")
        default: return kind
        }
    }

    func matches(query: String) -> Bool {
        PetdexSearchMatcher.matches(
            query: query,
            slug: slug,
            displayName: displayName,
            searchTerms: searchTerms,
            franchiseName: resolvedFranchiseName
        )
    }

    init(
        slug: String,
        displayName: String,
        kind: String,
        submittedBy: String?,
        spritesheetUrl: String,
        petJsonUrl: String,
        zipUrl: String,
        franchiseId: String? = nil,
        franchiseName: String? = nil,
        searchTerms: [String]? = nil
    ) {
        self.slug = slug
        self.displayName = displayName
        self.kind = kind
        self.submittedBy = submittedBy
        self.spritesheetUrl = spritesheetUrl
        self.petJsonUrl = petJsonUrl
        self.zipUrl = zipUrl
        self.franchiseId = franchiseId
        self.franchiseName = franchiseName
        self.searchTerms = searchTerms
    }

    init(entry: PetdexIndexEntry) {
        self.init(
            slug: entry.slug,
            displayName: entry.displayName,
            kind: entry.kind,
            submittedBy: nil,
            spritesheetUrl: entry.spritesheetUrl,
            petJsonUrl: entry.petJsonUrl,
            zipUrl: entry.zipUrl,
            franchiseId: entry.franchiseId,
            franchiseName: entry.franchiseName,
            searchTerms: entry.searchTerms
        )
    }
}

enum PetKindFilter: String, CaseIterable, Identifiable {
    case all
    case character
    case creature
    case object

    var id: String { rawValue }

    var label: String {
        switch self {
        case .all: return String(localized: "全部")
        case .character: return String(localized: "角色")
        case .creature: return String(localized: "生物")
        case .object: return String(localized: "物件")
        }
    }

    func matches(_ kind: String) -> Bool {
        switch self {
        case .all: return true
        default: return kind.lowercased() == rawValue
        }
    }
}

struct PetBrowseSection: Identifiable, Equatable {
    let id: String
    let title: String
    let pets: [PetBrowseItem]
}

struct PetBrowseItem: Identifiable, Equatable {
    let id: String
    let displayName: String
    let kindLabel: String
    let spritesheetURL: URL?
    let remotePet: PetdexRemotePet?
    let isInstalled: Bool
    let isSelected: Bool
    let franchiseId: String
}

struct InstalledPetItem: Identifiable, Equatable {
    let id: String
    let displayName: String
    let spritesheetURL: URL?
    let isSelected: Bool
}
