import Foundation

enum TimeFormat {
    static func duration(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        if h > 0 {
            return String(format: "%d小时%d分", h, m)
        }
        if m > 0 {
            return String(format: "%d分%d秒", m, s)
        }
        return String(format: "%d秒", s)
    }

    static func average(_ value: Double) -> String {
        duration(Int(value.rounded()))
    }

    static func shortDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "zh_CN")
        f.dateFormat = "M月d日 EEEE"
        return f.string(from: date)
    }
}
