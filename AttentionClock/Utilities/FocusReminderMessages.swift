import Foundation

enum FocusReminderMessages {
    static let effects = [
        "拯救前额叶一次",
        "高效成长一次",
        "深度思考一次",
        "积攒实力一次",
        "击退拖延一次",
        "夺回注意力一次",
        "心流体验一次",
        "为梦想蓄力一次",
        "对得起自己一次",
        "离目标更近一步",
    ]

    private static let indexKey = "focusReminderMessageIndex"

    static func nextEffect() -> String {
        let index = UserDefaults.standard.integer(forKey: indexKey) % effects.count
        let effect = effects[index]
        UserDefaults.standard.set((index + 1) % effects.count, forKey: indexKey)
        return effect
    }
}
