import SwiftUI

struct PetDetailView: View {
    @ObservedObject var petStore: PetStore
    let petId: String

    @State private var mapping: PetActionMapping = .default
    @State private var previewPhase: PetTimerActionPhase = .focus

    private var pack: CodexPetPack? {
        CodexPetPackLoader.loadPack(id: petId)
    }

    private var atlas: CodexPetAtlas? {
        guard let pack else { return nil }
        return CodexPetAtlas(pack: pack)
    }

    private var actionOptions: [PetActionOption] {
        guard let pack else { return [] }
        return PetActionCatalog.options(for: pack)
    }

    var body: some View {
        Group {
            if let pack, let atlas {
                detailContent(pack: pack, atlas: atlas)
            } else {
                ContentUnavailableView(
                    String(localized: "找不到伙伴"),
                    systemImage: "pawprint",
                    description: Text(String(localized: "该伙伴可能已被移除。"))
                )
            }
        }
        .navigationTitle(pack?.displayName ?? String(localized: "伙伴设置"))
        .onAppear {
            mapping = petStore.actionMapping(for: petId)
            petStore.selectInstalledPet(id: petId)
        }
    }

    private func detailContent(pack: CodexPetPack, atlas: CodexPetAtlas) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                previewCard(pack: pack, atlas: atlas)

                Text(String(localized: "为不同状态选择动作，专注奖励等特殊时刻仍会播放默认庆祝动作。"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                ForEach(PetTimerActionPhase.allCases) { phase in
                    phaseSection(phase: phase, pack: pack, atlas: atlas)
                }

                Button(String(localized: "恢复默认动作")) {
                    mapping = .default
                    persistMapping()
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.primary.opacity(0.06))
                )
            }
            .padding(20)
        }
    }

    private func previewCard(pack: CodexPetPack, atlas: CodexPetAtlas) -> some View {
        VStack(spacing: 12) {
            Picker(String(localized: "预览状态"), selection: $previewPhase) {
                ForEach(PetTimerActionPhase.allCases) { phase in
                    Text(phase.title).tag(phase)
                }
            }
            .pickerStyle(.segmented)

            PetActionRowPreview(
                atlas: atlas,
                pack: pack,
                row: previewPhase.row(in: mapping),
                displayWidth: 96
            )
            .frame(width: 96, height: 96 * atlas.aspectRatio)

            Text(previewLabel(for: previewPhase.row(in: mapping)))
                .font(.subheadline.weight(.medium))
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.primary.opacity(0.04))
        )
    }

    private func phaseSection(phase: PetTimerActionPhase, pack: CodexPetPack, atlas: CodexPetAtlas) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(phase.title)
                    .font(.headline)
                Text(phase.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            LazyVGrid(
                columns: [GridItem(.adaptive(minimum: 88), spacing: 10)],
                spacing: 10
            ) {
                ForEach(actionOptions) { option in
                    actionTile(
                        option: option,
                        isSelected: phase.row(in: mapping) == option.row,
                        atlas: atlas,
                        pack: pack
                    ) {
                        var updated = mapping
                        phase.setRow(option.row, in: &updated)
                        mapping = updated
                        previewPhase = phase
                        persistMapping()
                    }
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.primary.opacity(0.08), lineWidth: 1)
        )
    }

    private func actionTile(
        option: PetActionOption,
        isSelected: Bool,
        atlas: CodexPetAtlas,
        pack: CodexPetPack,
        onSelect: @escaping () -> Void
    ) -> some View {
        Button(action: onSelect) {
            VStack(spacing: 6) {
                PetActionRowPreview(
                    atlas: atlas,
                    pack: pack,
                    row: option.row,
                    displayWidth: 52
                )
                .frame(width: 52, height: 52 * atlas.aspectRatio)

                Text(option.name)
                    .font(.caption2.weight(isSelected ? .semibold : .regular))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isSelected ? Color.accentColor.opacity(0.16) : Color.primary.opacity(0.04))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(isSelected ? Color.accentColor.opacity(0.45) : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }

    private func previewLabel(for row: Int) -> String {
        guard let pack else { return "" }
        return PetActionCatalog.options(for: pack).first(where: { $0.row == row })?.name
            ?? PetActionCatalog.standardName(for: row)
    }

    private func persistMapping() {
        petStore.updateActionMapping(mapping, for: petId)
    }
}

struct PetActionRowPreview: View {
    let atlas: CodexPetAtlas
    let pack: CodexPetPack
    let row: Int
    var displayWidth: CGFloat = 48
    var fps: Double = 6

    var body: some View {
        let frameCount = max(pack.frameCount(forRow: row), 1)
        let interval = 1.0 / max(fps, 1)

        TimelineView(.periodic(from: .now, by: interval)) { context in
            let elapsed = max(context.date.timeIntervalSinceReferenceDate, 0)
            let frameIndex = Int(elapsed * fps) % frameCount

            SpritesheetPetCanvas(
                atlas: atlas,
                row: row,
                frameIndex: frameIndex,
                displayWidth: displayWidth,
                mirror: false
            )
        }
    }
}
