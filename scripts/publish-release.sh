#!/usr/bin/env bash
# Create GitHub Release v1.0.0 and upload all language/arch DMGs.
#
# Prerequisites:
#   brew install gh
#   gh auth login
#
# Usage:
#   ./scripts/publish-release.sh [version]

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

VERSION="${1:-1.1.0}"
TAG="v${VERSION}"
RELEASE_DIR="$ROOT/release"

if ! command -v gh >/dev/null 2>&1; then
  echo "GitHub CLI (gh) not found. Install: brew install gh" >&2
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "Not logged in to GitHub. Run: gh auth login" >&2
  exit 1
fi

DMGS=()
while IFS= read -r dmg; do
  DMGS+=("$dmg")
done < <(
  find "$RELEASE_DIR" -maxdepth 1 \( \
    -name "AttentionClock-${VERSION}-*-arm64.dmg" -o \
    -name "AttentionClock-${VERSION}-*-x86_64.dmg" \
  \) | sort
)

if [[ ${#DMGS[@]} -eq 0 ]]; then
  echo "No DMG files found. Run: ./scripts/build-release.sh ${VERSION}" >&2
  exit 1
fi

echo "Found ${#DMGS[@]} DMG files to upload."

if gh release view "$TAG" >/dev/null 2>&1; then
  echo "Release $TAG already exists. Uploading assets..."
  gh release upload "$TAG" "${DMGS[@]}" --clobber
else
  gh release create "$TAG" \
    --title "Attention Clock ${VERSION}" \
    --notes "$(cat <<EOF
## Attention Clock ${VERSION}

### 新功能
- **桌面宠物**：独立 Tab，浏览 Petdex 图鉴、搜索下载 3300+ 宠物伙伴
- **应用内图鉴同步**：自动/手动从 Petdex 拉取最新宠物列表
- **多语言搜索**：支持中文角色名搜索（路飞、皮卡丘等）

### 包含
- 21 种语言界面
- Apple 芯片 (arm64) 与 Intel (x86_64) 安装包
- 免费开源，数据本地保存

请根据你的 Mac 芯片和语言选择对应 \`.dmg\` 文件下载。
EOF
)" \
    "${DMGS[@]}"
fi

echo ""
echo "Release published: https://github.com/JackZhong1998/attentionclock/releases/tag/${TAG}"
