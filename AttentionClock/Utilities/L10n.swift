import Foundation

enum L10n {
    static func minutes(_ count: Int) -> String {
        String(format: String(localized: "%lld 分钟"), count)
    }

    static func sessionCompletedBody(minutes: Int, effect: String) -> String {
        String(format: String(localized: "已专注%lld分钟，%@"), minutes, effect)
    }

    static func catFedMinutes(_ minutes: Int) -> String {
        String(format: String(localized: "今天你陪了我 %lld 分钟，好开心！"), minutes)
    }

    static func totalCompletedSubtitle(_ count: Int) -> String {
        String(format: String(localized: "共 %lld 次"), count)
    }

    static func activeDaysSubtitle(_ days: Int) -> String {
        String(format: String(localized: "基于 %lld 个活跃日"), days)
    }

    static func completedTimes(_ count: Int) -> String {
        String(format: String(localized: "%lld 次"), count)
    }

    static func heatmapCompleted(_ count: Int, trees: String) -> String {
        String(format: String(localized: "完成 %lld 次 %@"), count, trees)
    }

    static func heatmapTooltip(date: String, detail: String, duration: String) -> String {
        String(format: String(localized: "%@\n%@ · 共 %@"), date, detail, duration)
    }

    static func heatmapNoRecord(date: String) -> String {
        String(format: String(localized: "%@：无专注记录"), date)
    }

    static func treeMultiplier(_ count: Int) -> String {
        String(format: String(localized: "🌳 ×%lld"), count)
    }
}
