import Foundation

struct PetdexIndexEntry: Codable, Identifiable, Equatable {
    let slug: String
    let displayName: String
    let kind: String
    let franchiseId: String
    let franchiseName: String
    let spritesheetUrl: String
    let petJsonUrl: String
    let zipUrl: String
    let searchTerms: [String]

    var id: String { slug }

    var spritesheetURL: URL? { URL(string: spritesheetUrl) }
    var petJsonURL: URL? { URL(string: petJsonUrl) }
    var zipURL: URL? { URL(string: zipUrl) }

    var remotePet: PetdexRemotePet {
        PetdexRemotePet(
            slug: slug,
            displayName: displayName,
            kind: kind,
            submittedBy: nil,
            spritesheetUrl: spritesheetUrl,
            petJsonUrl: petJsonUrl,
            zipUrl: zipUrl,
            franchiseId: franchiseId,
            franchiseName: franchiseName,
            searchTerms: searchTerms
        )
    }

    func matches(query: String) -> Bool {
        PetdexSearchMatcher.matches(
            query: query,
            slug: slug,
            displayName: displayName,
            searchTerms: searchTerms,
            franchiseName: franchiseName
        )
    }

    var kindLabel: String {
        switch kind.lowercased() {
        case "character": return String(localized: "角色")
        case "creature": return String(localized: "生物")
        case "object": return String(localized: "物件")
        default: return kind
        }
    }
}

struct PetdexIndexFile: Codable {
    let generatedAt: String?
    let total: Int?
    let pets: [PetdexIndexEntry]
}

struct PetdexFranchiseGroup: Identifiable, Equatable {
    let id: String
    let name: String
    let count: Int
    let previewSpritesheetURL: URL?
}

enum PetdexIndexLoader {
    private static let resourceName = "petdex-index"

    static func loadBundledIndex() -> [PetdexIndexEntry] {
        guard let url = Bundle.main.url(forResource: resourceName, withExtension: "json", subdirectory: "Petdex")
            ?? Bundle.main.url(forResource: resourceName, withExtension: "json") else {
            return []
        }
        guard let data = try? Data(contentsOf: url),
              let file = try? JSONDecoder().decode(PetdexIndexFile.self, from: data) else {
            return []
        }
        return file.pets
    }
}
