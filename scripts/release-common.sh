#!/usr/bin/env bash
# Shared release helpers for DMG packaging.

# shellcheck disable=SC2034
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/languages.conf"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

vol_name_for() {
  python3 -c "import json,sys; m=json.load(open('scripts/languages-metadata.json')); print(m['locales'][sys.argv[1]]['vol'])" "$1"
}

dmg_installer_name_for() {
  python3 -c "
import json, sys
ins = json.load(open('scripts/dmg-install-sections.json'))
en = ins['en']
loc = sys.argv[1]
print(ins.get(loc, en)['installer_app'])
" "$1"
}

dmg_guide_name_for() {
  python3 -c "
import json, sys
ins = json.load(open('scripts/dmg-install-sections.json'))
en = ins['en']
loc = sys.argv[1]
print(ins.get(loc, en)['guide_file'])
" "$1"
}

dmg_settings_link_for() {
  python3 -c "
import json, sys
ins = json.load(open('scripts/dmg-install-sections.json'))
en = ins['en']
loc = sys.argv[1]
print(ins.get(loc, en)['settings_link_file'])
" "$1"
}

ensure_dmg_assets() {
  if [[ ! -d "$ROOT/release/dmg-assets/$1" ]]; then
    echo "==> Generating DMG install assets..."
    python3 "$ROOT/scripts/generate-dmg-assets.py"
  fi
}

# Populate DMG staging: installer helper (with embedded app) + text guide.
prepare_dmg_staging() {
  local app_path="$1"
  local lang="$2"
  local staging="$3"

  ensure_dmg_assets "$lang"

  local assets="$ROOT/release/dmg-assets/$lang"
  local installer_name guide_name installer_app

  installer_name="$(dmg_installer_name_for "$lang")"
  guide_name="$(dmg_guide_name_for "$lang")"
  settings_link="$(dmg_settings_link_for "$lang")"
  installer_app="${installer_name}.app"

  rm -rf "$staging"
  mkdir -p "$staging"
  cp -R "$assets/$installer_app" "$staging/"
  mkdir -p "$staging/$installer_app/Contents/Resources"
  cp -R "$app_path" "$staging/$installer_app/Contents/Resources/AttentionClock.app"
  cp "$assets/$guide_name" "$staging/"
  cp "$assets/$settings_link" "$staging/"
  sign_app "$staging/$installer_app"

  echo "$installer_name"
}

sign_app() {
  local app="$1"
  echo "    Signing $(basename "$app") (ad-hoc)..." >&2
  codesign --force --deep --sign - --timestamp=none "$app" >&2
  codesign --verify --verbose=2 "$app" >&2
}

# Build a compressed DMG with Finder icon layout.
create_dmg() {
  local app_path="$1"
  local dmg_path="$2"
  local vol_name="$3"
  local lang="$4"

  local staging="release/.staging-$$"
  local installer_name guide_name rw_dmg mount_dir

  installer_name="$(prepare_dmg_staging "$app_path" "$lang" "$staging")"
  guide_name="$(dmg_guide_name_for "$lang")"
  settings_link="$(dmg_settings_link_for "$lang")"

  rw_dmg="${dmg_path%.dmg}.rw.dmg"
  rm -f "$rw_dmg" "$dmg_path"

  hdiutil create \
    -volname "$vol_name" \
    -srcfolder "$staging" \
    -ov \
    -format UDRW \
    "$rw_dmg"

  local attach_output device mount_dir
  attach_output="$(hdiutil attach -readwrite -noverify -noautoopen "$rw_dmg" 2>&1)" || {
    echo "$attach_output" >&2
    rm -f "$rw_dmg"
    rm -rf "$staging"
    exit 1
  }

  device="$(printf '%s\n' "$attach_output" | awk '/^\/dev\// {print $1; exit}')"
  mount_dir="$(printf '%s\n' "$attach_output" | grep '/Volumes/' | head -1 | sed -E 's|^.*(/Volumes/.+)$|\1|')"

  if [[ -z "$mount_dir" || ! -d "$mount_dir" ]]; then
    mount_dir="$(hdiutil info | awk -v dev="$device" '$1 == dev {print $3; exit}')"
  fi

  if [[ -n "$mount_dir" && -d "$mount_dir" ]]; then
    osascript "$ROOT/scripts/finalize-dmg-layout.applescript" \
      "$vol_name" \
      "${installer_name}.app" \
      "$guide_name" \
      "$settings_link" || echo "    (window layout skipped)" >&2
    chmod -Rf go-w "$mount_dir" 2>/dev/null || true
    sync
    if [[ -n "$device" ]]; then
      hdiutil detach "$device" -quiet || hdiutil detach "$mount_dir" -force
    else
      hdiutil detach "$mount_dir" -force
    fi
  else
    echo "    Warning: could not mount DMG for window layout" >&2
    hdiutil detach "$device" -quiet 2>/dev/null || true
  fi

  hdiutil convert "$rw_dmg" -format UDZO -imagekey zlib-level=9 -o "$dmg_path"
  rm -f "$rw_dmg"
  rm -rf "$staging"
}
