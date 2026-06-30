#!/usr/bin/env bash
# Build a single release DMG for the current machine architecture and language.
#
# Usage:
#   ./scripts/build-dmg.sh [version] [language]
#
# Examples:
#   ./scripts/build-dmg.sh 1.0.0 zh-Hans
#   ./scripts/build-dmg.sh 1.0.0 es
#
# Supported languages: see scripts/languages.conf

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
# shellcheck source=scripts/release-common.sh
source "$ROOT/scripts/release-common.sh"

VERSION="${1:-1.0.0}"
LANG="${2:-zh-Hans}"
ARCH="$(uname -m)"

if ! printf '%s\n' "${LANGUAGES[@]}" | grep -qx "$LANG"; then
  echo "Unsupported language: $LANG" >&2
  echo "Supported: ${LANGUAGES[*]}" >&2
  exit 1
fi

VOL_NAME="$(vol_name_for "$LANG")"
DMG_NAME="AttentionClock-${VERSION}-${LANG}-${ARCH}.dmg"
APP_PATH="build/DerivedData-${ARCH}/Build/Products/Release/AttentionClock.app"
WORK_APP="release/.work-AttentionClock-${LANG}-${ARCH}.app"

echo "Building AttentionClock ${VERSION} (${LANG}, ${ARCH})..."
xcodebuild \
  -project AttentionClock.xcodeproj \
  -scheme AttentionClock \
  -configuration Release \
  -derivedDataPath "build/DerivedData-${ARCH}" \
  ARCHS="$ARCH" \
  ONLY_ACTIVE_ARCH=NO \
  CODE_SIGN_IDENTITY="-" \
  CODE_SIGNING_ALLOWED=NO \
  build

rm -rf "$WORK_APP"
cp -R "$APP_PATH" "$WORK_APP"

RESOURCES="$WORK_APP/Contents/Resources"
for dir in "$RESOURCES"/*.lproj; do
  [[ -d "$dir" ]] || continue
  l="$(basename "$dir" .lproj)"
  if [[ "$l" != "$LANG" && "$l" != "Base" ]]; then
    rm -rf "$dir"
  fi
done

/usr/libexec/PlistBuddy -c "Set :CFBundleDevelopmentRegion $LANG" "$WORK_APP/Contents/Info.plist" 2>/dev/null \
  || /usr/libexec/PlistBuddy -c "Add :CFBundleDevelopmentRegion string $LANG" "$WORK_APP/Contents/Info.plist"

echo "Creating DMG..."
STAGING="release/dmg-staging"
rm -rf "$STAGING" "release/$DMG_NAME"
mkdir -p "$STAGING"
cp -R "$WORK_APP" "$STAGING/AttentionClock.app"
ln -s /Applications "$STAGING/Applications"
hdiutil create \
  -volname "$VOL_NAME" \
  -srcfolder "$STAGING" \
  -ov \
  -format UDZO \
  "release/$DMG_NAME"
rm -rf "$STAGING" "$WORK_APP"

echo "Done: release/$DMG_NAME"
ls -lh "release/$DMG_NAME"
