import Foundation

@MainActor
final class SessionStore: ObservableObject {
    @Published private(set) var sessions: [SessionRecord] = []

    private let fileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("AttentionClock", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("sessions.json")
        load()
    }

    func add(_ session: SessionRecord) {
        sessions.append(session)
        save()
    }

    func sessions(on day: Date, calendar: Calendar = .current) -> [SessionRecord] {
        sessions.filter { calendar.isDate($0.date, inSameDayAs: day) }
    }

    func completedCount(on day: Date, calendar: Calendar = .current) -> Int {
        sessions(on: day, calendar: calendar).filter(\.isCompleted).count
    }

    func totalSeconds(on day: Date, calendar: Calendar = .current) -> Int {
        sessions(on: day, calendar: calendar).reduce(0) { $0 + $1.elapsedSeconds }
    }

    var allCompletedCount: Int {
        sessions.filter(\.isCompleted).count
    }

    var allTotalSeconds: Int {
        sessions.reduce(0) { $0 + $1.elapsedSeconds }
    }

    var activeDays: Int {
        let calendar = Calendar.current
        let days = Set(sessions.map { calendar.startOfDay(for: $0.date) })
        return max(days.count, 1)
    }

    var averageDailyCompletedCount: Double {
        Double(allCompletedCount) / Double(activeDays)
    }

    var averageDailySeconds: Double {
        Double(allTotalSeconds) / Double(activeDays)
    }

    func dailyStatsList(calendar: Calendar = .current) -> [DailyStats] {
        let grouped = Dictionary(grouping: sessions) { calendar.startOfDay(for: $0.date) }
        return grouped.map { day, items in
            DailyStats(
                date: day,
                completedCount: items.filter(\.isCompleted).count,
                totalSeconds: items.reduce(0) { $0 + $1.elapsedSeconds }
            )
        }
        .sorted { $0.date > $1.date }
    }

    func heatmapGrid(weekCount: Int = 26, calendar: Calendar = .current) -> HeatmapGrid {
        let today = calendar.startOfDay(for: Date())
        guard let currentWeek = calendar.dateInterval(of: .weekOfYear, for: today) else {
            return HeatmapGrid(weeks: [], monthLabels: [], maxLevel: 4)
        }

        let gridStart = calendar.date(byAdding: .weekOfYear, value: -(weekCount - 1), to: currentWeek.start)!
        var weeks: [[HeatmapDay]] = []
        var monthLabels: [(weekIndex: Int, label: String)] = []
        var lastMonth = -1

        let monthFormatter = DateFormatter()
        monthFormatter.locale = Locale(identifier: "zh_CN")
        monthFormatter.dateFormat = "M月"

        for weekIndex in 0..<weekCount {
            guard let weekStart = calendar.date(byAdding: .weekOfYear, value: weekIndex, to: gridStart) else { continue }

            let month = calendar.component(.month, from: weekStart)
            if month != lastMonth {
                monthLabels.append((weekIndex: weekIndex, label: monthFormatter.string(from: weekStart)))
                lastMonth = month
            }

            var days: [HeatmapDay] = []
            for dayOffset in 0..<7 {
                guard let date = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) else { continue }
                let isFuture = date > today
                let completed = isFuture ? 0 : completedCount(on: date, calendar: calendar)
                let seconds = isFuture ? 0 : totalSeconds(on: date, calendar: calendar)
                let level = isFuture ? -1 : intensityLevel(completed: completed, totalSeconds: seconds)

                days.append(HeatmapDay(
                    date: date,
                    completedCount: completed,
                    totalSeconds: seconds,
                    level: level,
                    isFuture: isFuture
                ))
            }
            weeks.append(days)
        }

        return HeatmapGrid(weeks: weeks, monthLabels: monthLabels, maxLevel: 4)
    }

    private func intensityLevel(completed: Int, totalSeconds: Int) -> Int {
        if completed == 0 && totalSeconds == 0 { return 0 }

        let countLevel: Int = switch completed {
        case 0: 0
        case 1: 1
        case 2: 2
        case 3...4: 3
        default: 4
        }

        let minutes = totalSeconds / 60
        let timeLevel: Int = switch minutes {
        case 0: 0
        case 1...15: 1
        case 16...45: 2
        case 46...90: 3
        default: 4
        }

        return max(countLevel, timeLevel)
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([SessionRecord].self, from: data) else { return }
        sessions = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(sessions) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
