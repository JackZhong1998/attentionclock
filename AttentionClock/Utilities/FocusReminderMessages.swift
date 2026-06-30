import Foundation

enum FocusReminderMessages {
    static let effects: [String] = [
        String(localized: "拯救前额叶一次"),
        String(localized: "高效成长一次"),
        String(localized: "深度思考一次"),
        String(localized: "积攒实力一次"),
        String(localized: "击退拖延一次"),
        String(localized: "夺回注意力一次"),
        String(localized: "心流体验一次"),
        String(localized: "为梦想蓄力一次"),
        String(localized: "对得起自己一次"),
        String(localized: "离目标更近一步"),
    ]

    private static let indexKey = "focusReminderMessageIndex"

    static func nextEffect() -> String {
        let index = UserDefaults.standard.integer(forKey: indexKey) % effects.count
        let effect = effects[index]
        UserDefaults.standard.set((index + 1) % effects.count, forKey: indexKey)
        return effect
    }
}
