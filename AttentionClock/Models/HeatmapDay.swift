import Foundation

struct HeatmapDay: Identifiable {
    let date: Date
    let completedCount: Int
    let totalSeconds: Int
    let level: Int
    let isFuture: Bool

    var id: Date { date }
}

struct HeatmapGrid {
    let weeks: [[HeatmapDay]]
    let monthLabels: [(weekIndex: Int, label: String)]
    let maxLevel: Int
}
