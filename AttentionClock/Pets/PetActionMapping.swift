import Foundation

struct PetActionMapping: Codable, Equatable {
    var focusRow: Int
    var idleRow: Int
    var pausedRow: Int

    static let `default` = PetActionMapping(
        focusRow: CodexPetRow.idle,
        idleRow: CodexPetRow.idle,
        pausedRow: CodexPetRow.waiting
    )
}

enum PetTimerActionPhase: String, CaseIterable, Identifiable {
    case focus
    case idle
    case paused

    var id: String { rawValue }

    var title: String {
        switch self {
        case .focus: return String(localized: "专注")
        case .idle: return String(localized: "未专注")
        case .paused: return String(localized: "暂停")
        }
    }

    var subtitle: String {
        switch self {
        case .focus: return String(localized: "计时进行中时播放")
        case .idle: return String(localized: "未开始计时时播放")
        case .paused: return String(localized: "计时暂停时播放")
        }
    }

    func row(in mapping: PetActionMapping) -> Int {
        switch self {
        case .focus: return mapping.focusRow
        case .idle: return mapping.idleRow
        case .paused: return mapping.pausedRow
        }
    }

    func setRow(_ row: Int, in mapping: inout PetActionMapping) {
        switch self {
        case .focus: mapping.focusRow = row
        case .idle: mapping.idleRow = row
        case .paused: mapping.pausedRow = row
        }
    }

    var defaultRow: Int {
        switch self {
        case .focus: return CodexPetRow.idle
        case .idle: return CodexPetRow.idle
        case .paused: return CodexPetRow.waiting
        }
    }
}

struct PetActionOption: Identifiable, Equatable {
    let row: Int
    let name: String
    let frameCount: Int

    var id: Int { row }
}

enum PetActionCatalog {
    static func options(for pack: CodexPetPack) -> [PetActionOption] {
        let rowCount = min(pack.atlas.rows, 9)
        return (0..<rowCount).map { row in
            let name = pack.stateSpecs.first(where: { $0.row == row })?.name
                ?? standardName(for: row)
            return PetActionOption(
                row: row,
                name: name,
                frameCount: pack.frameCount(forRow: row)
            )
        }
    }

    static func standardName(for row: Int) -> String {
        switch row {
        case CodexPetRow.idle: return String(localized: "待机")
        case CodexPetRow.runningRight: return String(localized: "向右跑")
        case CodexPetRow.runningLeft: return String(localized: "向左跑")
        case CodexPetRow.waving: return String(localized: "挥手")
        case CodexPetRow.jumping: return String(localized: "跳跃")
        case CodexPetRow.failed: return String(localized: "沮丧")
        case CodexPetRow.waiting: return String(localized: "等待")
        case CodexPetRow.running: return String(localized: "奔跑")
        case CodexPetRow.review: return String(localized: "回顾")
        default: return String(localized: "动作 \(row + 1)")
        }
    }

    static func defaultFPS(for row: Int) -> Double {
        switch row {
        case CodexPetRow.idle: return 6
        case CodexPetRow.waiting: return 5
        case CodexPetRow.waving: return 10
        case CodexPetRow.jumping: return 8
        default: return 6
        }
    }
}

enum PetActionMappingStore {
    private static let storageKey = "petActionMappings"

    static func load(for petId: String) -> PetActionMapping {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let dictionary = try? JSONDecoder().decode([String: PetActionMapping].self, from: data),
              let mapping = dictionary[petId] else {
            return .default
        }
        return sanitized(mapping)
    }

    static func save(_ mapping: PetActionMapping, for petId: String) {
        var dictionary: [String: PetActionMapping] = [:]
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let stored = try? JSONDecoder().decode([String: PetActionMapping].self, from: data) {
            dictionary = stored
        }
        dictionary[petId] = sanitized(mapping)
        guard let data = try? JSONEncoder().encode(dictionary) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private static func sanitized(_ mapping: PetActionMapping) -> PetActionMapping {
        PetActionMapping(
            focusRow: clampRow(mapping.focusRow),
            idleRow: clampRow(mapping.idleRow),
            pausedRow: clampRow(mapping.pausedRow)
        )
    }

    private static func clampRow(_ row: Int) -> Int {
        min(max(row, 0), 8)
    }
}
