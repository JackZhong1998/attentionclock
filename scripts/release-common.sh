#!/usr/bin/env bash
# Shared language list for release builds.
# shellcheck disable=SC2034
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/languages.conf"

vol_name_for() {
  python3 -c "import json,sys; m=json.load(open('scripts/languages-metadata.json')); print(m['locales'][sys.argv[1]]['vol'])" "$1"
}

# Ad-hoc sign after we modify the .app bundle (strip languages, Info.plist, etc.).
# Note: downloaded apps still get Gatekeeper quarantine; users may need:
#   xattr -cr /Applications/AttentionClock.app
# For frictionless install, use Developer ID + notarization (see scripts/notarize-release.sh).
sign_app() {
  local app="$1"
  echo "    Signing $(basename "$app") (ad-hoc)..."
  codesign --force --deep --sign - --timestamp=none "$app"
  codesign --verify --verbose=2 "$app"
}
