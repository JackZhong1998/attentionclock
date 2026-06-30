import SwiftUI

struct FocusHeatmapView: View {
    let grid: HeatmapGrid

    private let cellSize: CGFloat = 14
    private let cellSpacing: CGFloat = 3
    private var weekdaySymbols: [String] {
        [
            String(localized: "日"),
            String(localized: "一"),
            String(localized: "二"),
            String(localized: "三"),
            String(localized: "四"),
            String(localized: "五"),
            String(localized: "六"),
        ]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if grid.weeks.isEmpty {
                Text("热力图加载失败，请重启应用")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 100)
            } else {
                monthLabelRow
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 8) {
                        weekdayLabelColumn
                        weeksGrid
                    }
                }
                legendRow
            }
        }
        .frame(minHeight: 130)
    }

    private var monthLabelRow: some View {
        HStack(spacing: cellSpacing) {
            Color.clear.frame(width: 20, height: 1)
            HStack(spacing: cellSpacing) {
                ForEach(0..<grid.weeks.count, id: \.self) { weekIndex in
                    let label = grid.monthLabels.first { $0.weekIndex == weekIndex }?.label ?? ""
                    Text(label)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.secondary)
                        .frame(width: cellSize, alignment: .leading)
                }
            }
        }
        .frame(height: 14)
    }

    private var weekdayLabelColumn: some View {
        VStack(spacing: cellSpacing) {
            ForEach(0..<7, id: \.self) { row in
                Text(row % 2 == 1 ? weekdaySymbols[row] : "")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.secondary)
                    .frame(width: 16, height: cellSize)
            }
        }
    }

    private var weeksGrid: some View {
        HStack(alignment: .top, spacing: cellSpacing) {
            ForEach(Array(grid.weeks.enumerated()), id: \.offset) { _, week in
                VStack(spacing: cellSpacing) {
                    ForEach(week) { day in
                        cell(for: day)
                    }
                }
            }
        }
    }

    private func cell(for day: HeatmapDay) -> some View {
        RoundedRectangle(cornerRadius: 3, style: .continuous)
            .fill(color(for: day))
            .overlay(
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .strokeBorder(Color.primary.opacity(day.isFuture ? 0.04 : 0.10), lineWidth: 0.5)
            )
            .frame(width: cellSize, height: cellSize)
            .help(tooltip(for: day))
    }

    private var legendRow: some View {
        HStack(spacing: 6) {
            Spacer()
            Text("少")
                .font(.caption2)
                .foregroundStyle(.tertiary)
            ForEach(0...grid.maxLevel, id: \.self) { level in
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(colorForLevel(level, isFuture: false))
                    .overlay(
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .strokeBorder(Color.primary.opacity(0.10), lineWidth: 0.5)
                    )
                    .frame(width: 14, height: 14)
            }
            Text("多")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.top, 4)
    }

    private func color(for day: HeatmapDay) -> Color {
        if day.isFuture { return Color.primary.opacity(0.03) }
        return colorForLevel(day.level, isFuture: false)
    }

    private func colorForLevel(_ level: Int, isFuture: Bool) -> Color {
        if isFuture { return Color.primary.opacity(0.03) }
        switch level {
        case 0: return Color(red: 0.90, green: 0.93, blue: 0.90)
        case 1: return Color(red: 0.72, green: 0.88, blue: 0.72)
        case 2: return Color(red: 0.50, green: 0.78, blue: 0.50)
        case 3: return Color(red: 0.32, green: 0.65, blue: 0.36)
        case 4: return Color(red: 0.18, green: 0.50, blue: 0.24)
        default: return Color(red: 0.12, green: 0.42, blue: 0.18)
        }
    }

    private func tooltip(for day: HeatmapDay) -> String {
        if day.isFuture { return "" }
        let dateStr = TimeFormat.heatmapDate(day.date)

        if day.level == 0 {
            return L10n.heatmapNoRecord(date: dateStr)
        }
        let trees = String(repeating: "🌳", count: min(day.completedCount, 6))
        let countPart = day.completedCount > 0
            ? L10n.heatmapCompleted(day.completedCount, trees: trees)
            : String(localized: "未完成")
        let timePart = TimeFormat.duration(day.totalSeconds)
        return L10n.heatmapTooltip(date: dateStr, detail: countPart, duration: timePart)
    }
}
