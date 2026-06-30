#!/usr/bin/env bash
# Shared language list for release builds.
# shellcheck disable=SC2034
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/languages.conf"

vol_name_for() {
  python3 -c "import json,sys; m=json.load(open('scripts/languages-metadata.json')); print(m['locales'][sys.argv[1]]['vol'])" "$1"
}
