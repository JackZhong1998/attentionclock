import Foundation

enum TimeFormat {
    static func duration(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        if h > 0 {
            return String(format: String(localized: "%d小时%d分"), h, m)
        }
        if m > 0 {
            return String(format: String(localized: "%d分%d秒"), m, s)
        }
        return String(format: String(localized: "%d秒"), s)
    }

    static func average(_ value: Double) -> String {
        duration(Int(value.rounded()))
    }

    static func shortDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = .current
        f.setLocalizedDateFormatFromTemplate(String(localized: "M月d日 EEEE"))
        return f.string(from: date)
    }

    static func heatmapDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = .current
        f.setLocalizedDateFormatFromTemplate(String(localized: "yyyy年M月d日"))
        return f.string(from: date)
    }

    static func heatmapMonth(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = .current
        f.setLocalizedDateFormatFromTemplate(String(localized: "M月"))
        return f.string(from: date)
    }
}
