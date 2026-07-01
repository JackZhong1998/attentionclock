#!/usr/bin/env bash
# Build language-specific, architecture-specific release DMGs.
#
# Usage:
#   ./scripts/build-release.sh [version]
#
# Output: AttentionClock-{version}-{lang}-{arch}.dmg (21 langs × 2 archs = 42 DMGs)

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
# shellcheck source=scripts/release-common.sh
source "$ROOT/scripts/release-common.sh"

VERSION="${1:-1.0.0}"
ARCHS=(arm64 x86_64)

strip_localizations() {
  local app="$1"
  local keep="$2"
  local resources="$app/Contents/Resources"

  for dir in "$resources"/*.lproj; do
    [[ -d "$dir" ]] || continue
    local lang
    lang="$(basename "$dir" .lproj)"
    if [[ "$lang" != "$keep" && "$lang" != "Base" ]]; then
      rm -rf "$dir"
    fi
  done

  /usr/libexec/PlistBuddy -c "Set :CFBundleDevelopmentRegion $keep" "$app/Contents/Info.plist" 2>/dev/null \
    || /usr/libexec/PlistBuddy -c "Add :CFBundleDevelopmentRegion string $keep" "$app/Contents/Info.plist"

  if /usr/libexec/PlistBuddy -c "Print :CFBundleLocalizations" "$app/Contents/Info.plist" &>/dev/null; then
    /usr/libexec/PlistBuddy -c "Delete :CFBundleLocalizations" "$app/Contents/Info.plist"
  fi
  /usr/libexec/PlistBuddy -c "Add :CFBundleLocalizations array" "$app/Contents/Info.plist"
  /usr/libexec/PlistBuddy -c "Add :CFBundleLocalizations:0 string $keep" "$app/Contents/Info.plist"
}

build_arch() {
  local arch="$1"
  echo "==> Building Release ($arch)..."
  xcodebuild \
    -project AttentionClock.xcodeproj \
    -scheme AttentionClock \
    -configuration Release \
    -derivedDataPath "build/DerivedData-$arch" \
    ARCHS="$arch" \
    ONLY_ACTIVE_ARCH=NO \
    CODE_SIGN_IDENTITY="-" \
    CODE_SIGNING_ALLOWED=NO \
    build
}

create_dmg() {
  local app_path="$1"
  local dmg_path="$2"
  local vol_name="$3"
  local staging="release/.staging-$$"

  rm -rf "$staging" "$dmg_path"
  mkdir -p "$staging"
  cp -R "$app_path" "$staging/AttentionClock.app"
  ln -s /Applications "$staging/Applications"
  hdiutil create \
    -volname "$vol_name" \
    -srcfolder "$staging" \
    -ov \
    -format UDZO \
    "$dmg_path"
  rm -rf "$staging"
}

mkdir -p release

for arch in "${ARCHS[@]}"; do
  build_arch "$arch"
  SRC_APP="build/DerivedData-$arch/Build/Products/Release/AttentionClock.app"

  for lang in "${LANGUAGES[@]}"; do
    WORK_APP="release/.work-AttentionClock-${lang}-${arch}.app"
    DMG_NAME="AttentionClock-${VERSION}-${lang}-${arch}.dmg"
    VOL_NAME="$(vol_name_for "$lang")"

    echo "==> Packaging $lang / $arch -> release/$DMG_NAME"
    rm -rf "$WORK_APP"
    cp -R "$SRC_APP" "$WORK_APP"
    strip_localizations "$WORK_APP" "$lang"
    create_dmg "$WORK_APP" "release/$DMG_NAME" "$VOL_NAME"
    rm -rf "$WORK_APP"
  done
done

echo ""
echo "Built ${#LANGUAGES[@]} languages × ${#ARCHS[@]} architectures:"
ls -lh release/AttentionClock-"${VERSION}"-*.dmg | wc -l | xargs echo "  DMG count:"
