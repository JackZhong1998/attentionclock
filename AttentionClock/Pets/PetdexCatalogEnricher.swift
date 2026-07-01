import Foundation

enum PetdexCatalogEnricher {
    private static let kindLabels: [String: [String]] = [
        "character": ["角色", "character", "キャラクター", "캐릭터"],
        "creature": ["生物", "creature", "クリーチャー", "생물"],
        "object": ["物件", "object", "オブジェクト", "물건"],
    ]

    static func enrich(_ pet: PetdexRemotePet, preservingMetadataFrom existing: PetdexRemotePet?) -> PetdexRemotePet {
        let franchise: PetdexFranchise
        let searchTerms: [String]

        if let existing,
           let terms = existing.searchTerms,
           !terms.isEmpty,
           let franchiseId = existing.franchiseId,
           let franchiseName = existing.franchiseName {
            franchise = PetdexFranchise(id: franchiseId, name: franchiseName, keywords: [])
            searchTerms = terms
        } else {
            let resolved = PetdexFranchiseCatalog.franchise(for: pet.slug, displayName: pet.displayName, kind: pet.kind)
            franchise = resolved
            searchTerms = buildSearchTerms(
                slug: pet.slug,
                displayName: pet.displayName,
                kind: pet.kind,
                franchise: resolved
            )
        }

        return PetdexRemotePet(
            slug: pet.slug,
            displayName: pet.displayName,
            kind: pet.kind,
            submittedBy: pet.submittedBy ?? existing?.submittedBy,
            spritesheetUrl: pet.spritesheetUrl,
            petJsonUrl: pet.petJsonUrl,
            zipUrl: pet.zipUrl,
            franchiseId: existing?.franchiseId ?? franchise.id,
            franchiseName: existing?.franchiseName ?? franchise.name,
            searchTerms: searchTerms
        )
    }

    static func buildSearchTerms(slug: String, displayName: String, kind: String, franchise: PetdexFranchise) -> [String] {
        var terms = Set<String>()
        terms.insert(slug.lowercased())
        terms.insert(displayName.lowercased())
        terms.insert(slug.replacingOccurrences(of: "-", with: " ").lowercased())
        terms.insert(franchise.name.lowercased())

        for label in kindLabels[kind.lowercased()] ?? [] {
            terms.insert(label.lowercased())
        }

        let haystack = "\(displayName) \(slug)".lowercased()
        for keyword in franchise.keywords where haystack.contains(keyword.lowercased()) {
            terms.insert(keyword.lowercased())
        }

        for alias in PetdexSearchMatcher.aliases(for: slug, displayName: displayName) {
            terms.insert(alias.lowercased())
        }

        return terms.filter { !$0.isEmpty }.sorted()
    }
}
