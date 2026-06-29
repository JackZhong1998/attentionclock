import Foundation

enum SessionEndReason: String, Codable {
    case completed
    case paused
    case ended
}

struct SessionRecord: Codable, Identifiable {
    let id: UUID
    let date: Date
    let elapsedSeconds: Int
    let plannedSeconds: Int
    let reason: SessionEndReason

    var isCompleted: Bool { reason == .completed }
}

struct DailyStats: Identifiable {
    let date: Date
    let completedCount: Int
    let totalSeconds: Int

    var id: Date { date }

    var treeDisplay: String {
        String(repeating: "🌳", count: min(completedCount, 20))
            + (completedCount > 20 ? " +\(completedCount - 20)" : "")
    }
}
