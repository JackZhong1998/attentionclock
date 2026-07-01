import Foundation

struct PetdexFranchise: Identifiable, Equatable {
    let id: String
    let name: String
    let keywords: [String]

    static let other = PetdexFranchise(id: "other", name: String(localized: "其他"), keywords: [])
}

enum PetdexFranchiseCatalog {
    static let franchises: [PetdexFranchise] = [
        PetdexFranchise(id: "pokemon", name: "宝可梦", keywords: [
            "pokemon", "pokémon", "pikachu", "snorlax", "charizard", "eevee", "mewtwo", "gengar", "jigglypuff", "squirtle"
        ]),
        PetdexFranchise(id: "lol", name: "英雄联盟", keywords: [
            "league of legends", "league-of", "lux", "ahri", "jinx", "yasuo", "teemo", "garen", "summoner"
        ]),
        PetdexFranchise(id: "jojo", name: "JOJO 的奇妙冒险", keywords: [
            "jojo", "jotaro", "jolyne", "dio", "giorno", "stands"
        ]),
        PetdexFranchise(id: "genshin", name: "原神", keywords: [
            "genshin", "原神", "paimon", "zhongli", "raiden", "furina", "nahida", "venti"
        ]),
        PetdexFranchise(id: "naruto", name: "火影忍者", keywords: [
            "naruto", "sasuke", "kakashi", "火影"
        ]),
        PetdexFranchise(id: "onepiece", name: "海贼王", keywords: [
            "one piece", "onepiece", "luffy", "zoro", "chopper", "海贼王"
        ]),
        PetdexFranchise(id: "zelda", name: "塞尔达", keywords: [
            "zelda", "link", "hyrule", "totk", "botw"
        ]),
        PetdexFranchise(id: "mario", name: "马里奥", keywords: [
            "mario", "luigi", "bowser", "yoshi", "peach"
        ]),
        PetdexFranchise(id: "disney", name: "迪士尼", keywords: [
            "disney", "mickey", "stitch", "elsa", "frozen"
        ]),
        PetdexFranchise(id: "marvel", name: "漫威", keywords: [
            "marvel", "spider-man", "spiderman", "iron man", "deadpool", "homelander"
        ]),
        PetdexFranchise(id: "dc", name: "DC", keywords: [
            "batman", "superman", "joker", "wonder woman"
        ]),
        PetdexFranchise(id: "sanrio", name: "三丽鸥", keywords: [
            "hello kitty", "sanrio", "kuromi", "cinnamoroll", "my melody"
        ]),
        PetdexFranchise(id: "animal", name: "动物伙伴", keywords: [
            "cat", "dog", "penguin", "fox", "bear", "rabbit", "owl", "hamster", "小猫", "小猫", "climber-cat", "belayer-cat"
        ]),
        PetdexFranchise(id: "robot", name: "机器人", keywords: [
            "robot", "mecha", "tiko", "android", "cyber"
        ]),
    ]

    static func franchise(for slug: String, displayName: String, kind: String) -> PetdexFranchise {
        let haystack = "\(displayName) \(slug)".lowercased()
        for franchise in franchises {
            if franchise.keywords.contains(where: { haystack.contains($0) }) {
                return franchise
            }
        }

        switch kind.lowercased() {
        case "creature":
            return PetdexFranchise(id: "creature-kind", name: String(localized: "生物"), keywords: [])
        case "object":
            return PetdexFranchise(id: "object-kind", name: String(localized: "物件"), keywords: [])
        case "character":
            return PetdexFranchise(id: "character-kind", name: String(localized: "原创角色"), keywords: [])
        default:
            return .other
        }
    }

    static var filterOptions: [PetdexFranchise] {
        franchises + [.other]
    }

    static var orderedFranchiseIDs: [String] {
        franchises.map(\.id) + ["creature-kind", "object-kind", "character-kind", PetdexFranchise.other.id]
    }
}
