import AppKit
import ImageIO
import SwiftUI

struct DesktopPetView: View {
    @ObservedObject var settings: SettingsStore
    @ObservedObject var petStore: PetStore
    @ObservedObject var catStore: CatStore
    @ObservedObject var timer: TimerViewModel

    @State private var searchText = ""
    @State private var kindFilter: PetKindFilter = .all
    @State private var franchiseFilter: String? = nil
    @State private var showSyncResult = false

    private var browseQuery: PetBrowseQuery {
        PetBrowseQuery(
            searchText: searchText,
            kindFilter: kindFilter,
            franchiseFilter: franchiseFilter
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            headerCard
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)

            if !petStore.installedItems().isEmpty {
                installedStrip
                    .padding(.bottom, 12)
            }

            filterBar
                .padding(.horizontal, 20)
                .padding(.bottom, 10)

            Divider()

            catalogBody
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(nsColor: .windowBackgroundColor))
        .task {
            await petStore.bootstrapCatalog()
        }
        .onChange(of: searchText) { _, _ in refreshBrowse() }
        .onChange(of: kindFilter) { _, _ in refreshBrowse() }
        .onChange(of: franchiseFilter) { _, _ in refreshBrowse() }
        .onChange(of: petStore.remotePets.count) { _, _ in refreshBrowse() }
        .onChange(of: petStore.selectedPetId) { _, _ in refreshBrowse() }
        .onAppear { refreshBrowse() }
        .onChange(of: petStore.lastSyncResultMessage) { _, message in
            showSyncResult = message != nil
        }
        .alert(String(localized: "导入失败"), isPresented: importErrorBinding) {
            Button(String(localized: "好的"), role: .cancel) {}
        } message: {
            Text(petStore.importError ?? "")
        }
        .alert(String(localized: "图鉴同步"), isPresented: $showSyncResult) {
            Button(String(localized: "好的"), role: .cancel) {
                petStore.lastSyncResultMessage = nil
            }
        } message: {
            Text(petStore.lastSyncResultMessage ?? "")
        }
    }

    private var headerCard: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 10) {
                if !settings.desktopPetEnabled {
                    Text(String(localized: "开启桌面伙伴后，可从图鉴下载角色陪你专注，或显示在桌面上。"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Toggle(String(localized: "开启桌面伙伴"), isOn: $settings.desktopPetEnabled)
                Toggle(String(localized: "桌面浮窗"), isOn: $settings.floatingCatEnabled)
                    .disabled(!settings.desktopPetEnabled)
            }

            Spacer(minLength: 8)

            if settings.desktopPetEnabled, petStore.hasSelectedPet {
                VStack(spacing: 6) {
                    PetStatusBubble(text: catStore.companionBubbleLabel(timerPhase: timer.phase))

                    CatSpriteView(
                        petStore: petStore,
                        timerPhase: timer.phase,
                        expression: catStore.expression,
                        behavior: activeBehavior,
                        pendingReward: catStore.pendingRewardNotice,
                        displayWidth: 64
                    )
                    .frame(width: 64, height: 70)
                    .frame(maxWidth: .infinity)

                    Text(selectedPetName)
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(1)
                }
                .frame(minWidth: 88)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.primary.opacity(0.04))
        )
    }

    private var selectedPetName: String {
        petStore.activePack?.displayName
            ?? petStore.installedItems().first(where: \.isSelected)?.displayName
            ?? ""
    }

    private var installedStrip: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("已下载")
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(petStore.installedItems()) { item in
                        InstalledPetChip(item: item) {
                            petStore.selectInstalledPet(id: item.id)
                            if !settings.desktopPetEnabled {
                                settings.desktopPetEnabled = true
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private var filterBar: some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField(String(localized: "搜索伙伴（支持中文/英文/日文等）"), text: $searchText)
                    .textFieldStyle(.plain)
                Button {
                    Task { await petStore.syncCatalog() }
                } label: {
                    if petStore.catalogSyncInfo.isSyncing {
                        ProgressView().controlSize(.small)
                    } else {
                        Label(String(localized: "同步图鉴"), systemImage: "arrow.clockwise")
                            .labelStyle(.iconOnly)
                    }
                }
                .buttonStyle(.plain)
                .help(String(localized: "从 Petdex 拉取最新伙伴列表"))
                .disabled(petStore.catalogSyncInfo.isSyncing)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.primary.opacity(0.05))
            )

            HStack(spacing: 8) {
                Text(syncStatusText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Spacer(minLength: 0)
                if let error = petStore.catalogSyncInfo.lastError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .lineLimit(1)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(PetKindFilter.allCases) { filter in
                        filterChip(title: filter.label, isSelected: kindFilter == filter) {
                            kindFilter = kindFilter == filter ? .all : filter
                        }
                    }

                    Divider().frame(height: 18)

                    filterChip(title: String(localized: "全部系列"), isSelected: franchiseFilter == nil) {
                        franchiseFilter = nil
                    }

                    ForEach(PetdexFranchiseCatalog.filterOptions) { franchise in
                        filterChip(title: franchise.name, isSelected: franchiseFilter == franchise.id) {
                            franchiseFilter = franchiseFilter == franchise.id ? nil : franchise.id
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }

    @ViewBuilder
    private var catalogBody: some View {
        let snapshot = petStore.browseSnapshot

        if !snapshot.franchiseOverview.isEmpty {
            franchiseOverview(snapshot.franchiseOverview)
        } else if snapshot.sections.isEmpty {
            ScrollView {
                Text(emptyCatalogMessage)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(24)
                    .frame(maxWidth: .infinity)
            }
        } else {
            petGridSections(snapshot.sections, total: snapshot.totalMatches)
        }
    }

    private func franchiseOverview(_ groups: [PetdexFranchiseGroup]) -> some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 220), spacing: 12)], spacing: 12) {
                ForEach(groups) { group in
                    Button {
                        franchiseFilter = group.id
                    } label: {
                        FranchiseGroupCard(group: group)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(20)
        }
    }

    private func petGridSections(_ sections: [PetBrowseSection], total: Int) -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 18, pinnedViews: [.sectionHeaders]) {
                if total > PetStore.pageSize {
                    Text("显示前 \(PetStore.pageSize) 个结果，请使用搜索或系列筛选缩小范围。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                }

                ForEach(sections) { section in
                    Section {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 148), spacing: 12)], spacing: 12) {
                            ForEach(section.pets) { item in
                                PetBrowseCard(
                                    item: item,
                                    isImporting: petStore.importingPetId == item.id,
                                    onAction: { Task { await handleAction(for: item) } }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    } header: {
                        HStack {
                            Text(section.title).font(.headline)
                            Text("\(section.pets.count)")
                                .font(.caption.weight(.semibold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Capsule().fill(Color.primary.opacity(0.08)))
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .padding(.bottom, 4)
                        .background(Color(nsColor: .windowBackgroundColor))
                    }
                }
            }
            .padding(.bottom, 20)
        }
    }

    private var syncStatusText: String {
        let info = petStore.catalogSyncInfo
        if info.isSyncing {
            return String(localized: "正在同步图鉴…")
        }
        if let lastSyncedAt = info.lastSyncedAt {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .short
            let relative = formatter.localizedString(for: lastSyncedAt, relativeTo: Date())
            return String(localized: "共 \(info.totalCount) 个 · 上次同步 \(relative)")
        }
        return String(localized: "共 \(info.totalCount) 个 · 尚未同步")
    }

    private var emptyCatalogMessage: String {
        if let error = petStore.catalogError {
            return error
        }
        return String(localized: "没有匹配的伙伴，试试其他关键词或筛选条件。")
    }

    private var activeBehavior: CatBehavior {
        switch timer.phase {
        case .running, .paused: return .focusCompanion
        case .idle: return .idleRoaming
        }
    }

    private var importErrorBinding: Binding<Bool> {
        Binding(
            get: { petStore.importError != nil },
            set: { if !$0 { petStore.importError = nil } }
        )
    }

    private func refreshBrowse() {
        petStore.refreshBrowseSnapshot(query: browseQuery)
    }

    private func handleAction(for item: PetBrowseItem) async {
        if item.isInstalled {
            petStore.selectInstalledPet(id: item.id)
            if !settings.desktopPetEnabled { settings.desktopPetEnabled = true }
            return
        }
        guard let remote = item.remotePet else { return }
        if await petStore.installAndSelect(remote) {
            if !settings.desktopPetEnabled { settings.desktopPetEnabled = true }
            refreshBrowse()
        }
    }

    private func filterChip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.medium))
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(
                    Capsule().fill(isSelected ? Color.accentColor.opacity(0.18) : Color.primary.opacity(0.06))
                )
        }
        .buttonStyle(.plain)
    }
}

private struct InstalledPetChip: View {
    let item: InstalledPetItem
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(item.isSelected ? Color.accentColor.opacity(0.14) : Color.primary.opacity(0.05))
                        .frame(width: 72, height: 72)
                    if let url = item.spritesheetURL {
                        PetThumbnailView(spritesheetURL: url)
                            .frame(width: 56, height: 56)
                    }
                }
                Text(item.displayName)
                    .font(.caption2.weight(item.isSelected ? .semibold : .regular))
                    .lineLimit(1)
                    .frame(width: 72)
            }
        }
        .buttonStyle(.plain)
    }
}

private struct FranchiseGroupCard: View {
    let group: PetdexFranchiseGroup

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.primary.opacity(0.05))
                    .frame(height: 88)
                if let url = group.previewSpritesheetURL {
                    PetThumbnailView(spritesheetURL: url)
                        .frame(height: 72)
                }
            }
            HStack {
                Text(group.name)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text("\(group.count)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
        )
    }
}

private struct PetBrowseCard: View {
    let item: PetBrowseItem
    let isImporting: Bool
    let onAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.primary.opacity(0.04))
                    .frame(height: 108)

                if let url = item.spritesheetURL {
                    PetThumbnailView(spritesheetURL: url)
                        .frame(height: 88)
                }

                if item.isSelected {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(.white, .green)
                                .padding(8)
                        }
                        Spacer()
                    }
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(item.displayName)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                Text(item.kindLabel)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Button(action: onAction) {
                Group {
                    if isImporting {
                        ProgressView().controlSize(.small)
                    } else {
                        Text(buttonTitle)
                            .font(.caption.weight(.semibold))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
            .buttonStyle(.plain)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(item.isSelected ? Color.accentColor.opacity(0.16) : Color.primary.opacity(0.06))
            )
            .disabled(isImporting)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
        )
    }

    private var buttonTitle: String {
        if item.isSelected { return String(localized: "当前伙伴") }
        if item.isInstalled { return String(localized: "选用") }
        return String(localized: "下载")
    }
}

private struct PetThumbnailView: View {
    let spritesheetURL: URL
    @State private var image: NSImage?

    var body: some View {
        Group {
            if let image {
                Image(nsImage: image)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 88)
            } else {
                ProgressView().controlSize(.small)
            }
        }
        .task(id: spritesheetURL) {
            image = await PetThumbnailLoader.thumbnail(for: spritesheetURL)
        }
    }
}

private enum PetThumbnailLoader {
    static func thumbnail(for url: URL) async -> NSImage? {
        if url.isFileURL, let atlas = loadLocalAtlas(url: url) {
            return atlas.nsImage(row: 0, column: 0)
        }

        var request = URLRequest(url: url)
        request.setValue("AttentionClock/1.0", forHTTPHeaderField: "User-Agent")
        guard let (data, response) = try? await URLSession.shared.data(for: request),
              let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode),
              let source = CGImageSourceCreateWithData(data as CFData, nil),
              let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            return nil
        }

        let columns = 8
        let rows = 9
        let cellW = cgImage.width / columns
        let cellH = cgImage.height / rows
        let y = cgImage.height - cellH
        let rect = CGRect(x: 0, y: y, width: cellW, height: cellH)
        guard let cropped = cgImage.cropping(to: rect) else { return nil }
        return NSImage(cgImage: cropped, size: NSSize(width: cellW, height: cellH))
    }

    private static func loadLocalAtlas(url: URL) -> CodexPetAtlas? {
        let directory = url.deletingLastPathComponent()
        guard let pack = CodexPetPackLoader.loadPack(from: directory) else { return nil }
        return CodexPetAtlas(pack: pack)
    }
}
