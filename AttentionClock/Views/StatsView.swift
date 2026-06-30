import SwiftUI

struct StatsView: View {
    @ObservedObject var sessionStore: SessionStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                heatmapSection
                todaySection
                summarySection
                historySection
            }
            .padding(32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var todaySection: some View {
        let count = sessionStore.completedCount(on: Date())
        let seconds = sessionStore.totalSeconds(on: Date())

        return VStack(alignment: .leading, spacing: 12) {
            Text("今天")
                .font(.title2.weight(.semibold))

            HStack(spacing: 32) {
                statCard(
                    title: "完成次数",
                    value: treeString(count),
                    subtitle: count == 0 ? "还没有完成的专注" : "每完成一次种一棵树"
                )
                statCard(
                    title: "总时长",
                    value: TimeFormat.duration(seconds),
                    subtitle: "含完成、暂停与提前结束"
                )
            }
        }
    }

    private var heatmapSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("专注热力图")
                .font(.title2.weight(.semibold))

            Text("过去 26 周每日专注情况，颜色越深表示越活跃")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            FocusHeatmapView(grid: sessionStore.heatmapGrid())
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.primary.opacity(0.03))
                )
        }
    }

    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("全部汇总")
                .font(.title2.weight(.semibold))

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                statCard(
                    title: "累计完成",
                    value: treeString(sessionStore.allCompletedCount),
                    subtitle: L10n.totalCompletedSubtitle(sessionStore.allCompletedCount)
                )
                statCard(
                    title: "累计时长",
                    value: TimeFormat.duration(sessionStore.allTotalSeconds),
                    subtitle: "所有记录合计"
                )
                statCard(
                    title: "日均次数",
                    value: String(format: "%.1f", sessionStore.averageDailyCompletedCount),
                    subtitle: L10n.activeDaysSubtitle(sessionStore.activeDays)
                )
                statCard(
                    title: "日均时长",
                    value: TimeFormat.average(sessionStore.averageDailySeconds),
                    subtitle: "平均每天专注时长"
                )
            }
        }
    }

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("每日记录")
                .font(.title2.weight(.semibold))

            if sessionStore.dailyStatsList().isEmpty {
                Text("暂无记录，开始第一次专注吧")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 24)
            } else {
                VStack(spacing: 0) {
                    ForEach(sessionStore.dailyStatsList()) { day in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(TimeFormat.shortDate(day.date))
                                    .font(.body.weight(.medium))
                                Text(day.treeDisplay)
                                    .font(.title3)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 4) {
                                Text(L10n.completedTimes(day.completedCount))
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                                Text(TimeFormat.duration(day.totalSeconds))
                                    .font(.subheadline)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        .padding(.vertical, 14)
                        .padding(.horizontal, 4)

                        if day.id != sessionStore.dailyStatsList().last?.id {
                            Divider()
                        }
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.primary.opacity(0.03))
                )
            }
        }
    }

    private func statCard(title: String, value: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title2.weight(.medium))
                .lineLimit(2)
                .minimumScaleFactor(0.7)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.primary.opacity(0.03))
        )
    }

    private func treeString(_ count: Int) -> String {
        if count == 0 { return "—" }
        if count <= 12 { return String(repeating: "🌳", count: count) }
        return String(repeating: "🌳", count: 8) + " " + L10n.treeMultiplier(count)
    }
}
