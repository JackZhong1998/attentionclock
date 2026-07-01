import Foundation

enum PetdexSearchMatcher {
    private static let aliasTable: [String: [String]] = loadAliasTable()

    static func normalize(_ query: String) -> String {
        var q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let suffixes = ["的", "之一", "酱", "ちゃん", "sama", "san"]
        for suffix in suffixes {
            if q.hasSuffix(suffix), q.count > suffix.count {
                q = String(q.dropLast(suffix.count))
            }
        }
        return q.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    static func aliases(for slug: String, displayName: String) -> [String] {
        let hay = "\(slug) \(displayName)".lowercased()
        var result: [String] = []
        for (key, values) in aliasTable {
            if hay.contains(key) || slug.lowercased().split(separator: "-").contains(Substring(key)) {
                result.append(contentsOf: values)
            }
        }
        return result
    }

    static func matches(
        query: String,
        slug: String,
        displayName: String,
        searchTerms: [String]?,
        franchiseName: String? = nil
    ) -> Bool {
        let q = normalize(query)
        guard !q.isEmpty else { return true }

        var candidates = [slug, displayName, slug.replacingOccurrences(of: "-", with: " ")]
        if let searchTerms { candidates.append(contentsOf: searchTerms) }
        if let franchiseName, !franchiseName.isEmpty {
            candidates.append(franchiseName)
        }
        candidates.append(contentsOf: aliases(for: slug, displayName: displayName))

        return candidates.contains { term in
            let t = term.lowercased()
            return t.contains(q) || q.contains(t)
        }
    }

    private static func loadAliasTable() -> [String: [String]] {
        guard let url = Bundle.main.url(forResource: "pet-character-aliases", withExtension: "json")
            ?? Bundle.main.url(forResource: "pet-character-aliases", withExtension: "json", subdirectory: "Petdex"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([String: [String]].self, from: data) else {
            return [:]
        }
        return decoded
    }
}
