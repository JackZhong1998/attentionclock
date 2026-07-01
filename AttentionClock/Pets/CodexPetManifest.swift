import Foundation

struct CodexPetAtlasSpec: Equatable {
    let columns: Int
    let rows: Int
    let cellWidth: Int
    let cellHeight: Int

    static let standard = CodexPetAtlasSpec(columns: 8, rows: 9, cellWidth: 192, cellHeight: 208)

    static func derived(from imageWidth: Int, imageHeight: Int) -> CodexPetAtlasSpec {
        let columns = 8
        let rows = 9
        return CodexPetAtlasSpec(
            columns: columns,
            rows: rows,
            cellWidth: imageWidth / columns,
            cellHeight: imageHeight / rows
        )
    }
}

struct CodexPetStateSpec: Equatable {
    let name: String
    let row: Int
    let frames: Int
}

struct CodexPetManifest: Decodable {
    let id: String?
    let displayName: String?
    let name: String?
    let description: String?
    let spritesheetPath: String?
    let atlas: AtlasPayload?
    let states: [StatePayload]?

    struct AtlasPayload: Decodable {
        let width: Int?
        let height: Int?
        let columns: Int?
        let rows: Int?
        let cell_width: Int?
        let cell_height: Int?
    }

    struct StatePayload: Decodable {
        let name: String
        let row: Int
        let frames: Int
    }

    var resolvedId: String {
        id ?? displayName?.lowercased() ?? name?.lowercased() ?? "pet"
    }

    var resolvedDisplayName: String {
        displayName ?? name ?? resolvedId
    }

    var resolvedSpritesheetName: String {
        spritesheetPath ?? "spritesheet.webp"
    }

    var stateSpecs: [CodexPetStateSpec] {
        states?.map { CodexPetStateSpec(name: $0.name, row: $0.row, frames: $0.frames) } ?? []
    }

    func atlasSpec(imageWidth: Int, imageHeight: Int) -> CodexPetAtlasSpec {
        if let atlas,
           let columns = atlas.columns,
           let rows = atlas.rows,
           columns > 0,
           rows > 0 {
            let cellW = atlas.cell_width ?? (imageWidth / columns)
            let cellH = atlas.cell_height ?? (imageHeight / rows)
            return CodexPetAtlasSpec(columns: columns, rows: rows, cellWidth: cellW, cellHeight: cellH)
        }
        if imageWidth == 1536, imageHeight == 1872 {
            return .standard
        }
        return CodexPetAtlasSpec.derived(from: imageWidth, imageHeight: imageHeight)
    }

    func frameCount(forRow row: Int) -> Int {
        if let state = stateSpecs.first(where: { $0.row == row }) {
            return max(state.frames, 1)
        }
        return CodexPetRow.defaultFrameCount(for: row)
    }
}
