import Foundation

enum CatStage: String, Codable {
    case kitten
    case adult

    var label: String {
        switch self {
        case .kitten: return String(localized: "初识")
        case .adult: return String(localized: "熟络")
        }
    }
}

enum CatExpression: String {
    case happy
    case sleepy
    case hungry
    case waiting
    case celebrating

    var emoji: String {
        switch self {
        case .happy: return "😺"
        case .sleepy: return "😸"
        case .hungry: return "😿"
        case .waiting: return "🐱"
        case .celebrating: return "😻"
        }
    }

    var message: String {
        switch self {
        case .happy: return String(localized: "今天状态不错～")
        case .sleepy: return String(localized: "陪你专注中…")
        case .hungry: return String(localized: "好久没一起专注了")
        case .waiting: return String(localized: "点「开始专注」陪我吧")
        case .celebrating: return String(localized: "太好了！又一起专注啦")
        }
    }
}

struct CatState: Codable {
    var name: String
    var hunger: Int
    var mood: Int
    var affection: Int
    var totalFedCount: Int
    var lastInteractionDate: Date?
    var stage: CatStage

    static let initial = CatState(
        name: String(localized: "小伴"),
        hunger: 60,
        mood: 60,
        affection: 10,
        totalFedCount: 0,
        lastInteractionDate: nil,
        stage: .kitten
    )
}
