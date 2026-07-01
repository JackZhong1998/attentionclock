#!/usr/bin/env python3
"""Generate per-locale DMG helper app and plain-text install guide."""

from __future__ import annotations

import json
import plistlib
import re
import shutil
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
GATEKEEPER = json.loads((ROOT / "scripts" / "gatekeeper-sections.json").read_text(encoding="utf-8"))
INSTALL = json.loads((ROOT / "scripts" / "dmg-install-sections.json").read_text(encoding="utf-8"))
META = json.loads((ROOT / "scripts" / "languages-metadata.json").read_text(encoding="utf-8"))
OUT = ROOT / "release" / "dmg-assets"
APPLESCRIPT = ROOT / "scripts" / "dmg" / "Install.applescript"
SETTINGS_URL = "x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension"


def strip_md(text: str) -> str:
    return re.sub(r"\*\*([^*]+)\*\*", r"\1", text)


def install_for(locale: str) -> dict:
    if locale in INSTALL:
        return INSTALL[locale]
    base = INSTALL["en"].copy()
    g = GATEKEEPER.get(locale, GATEKEEPER["en"])
    base["post_install_body"] = (
        "The app is launching.\n\n"
        + strip_md(g.get("order_note", ""))
        + "\n\n"
        + 'Click "Open System Settings" below, then choose Open Anyway under Security.'
    )
    return base


def gatekeeper_for(locale: str) -> dict:
    return GATEKEEPER.get(locale, GATEKEEPER["en"])


def build_guide(locale: str) -> str:
    ins = install_for(locale)
    gk = gatekeeper_for(locale)
    lines = [
        ins["guide_title"],
        "=" * min(len(ins["guide_title"]), 48),
        "",
        ins["method1"],
        "",
        ins.get("settings_shortcut_line", INSTALL["en"]["settings_shortcut_line"]),
        "",
    ]
    if gk.get("installer_title"):
        lines += [
            strip_md(gk["installer_title"]),
            "-" * 40,
            strip_md(gk.get("installer_intro", "")),
            "",
        ]
        for i, step in enumerate(gk.get("installer_steps", []), 1):
            lines.append(f"{i}. {strip_md(step)}")
        if gk.get("installer_order_note"):
            lines += ["", strip_md(gk["installer_order_note"]), ""]
    lines += [
        strip_md(gk["title"]),
        "-" * 40,
        strip_md(gk["intro"]),
        "",
    ]
    for i, step in enumerate(gk["steps"], 1):
        lines.append(f"{i}. {strip_md(step)}")
    lines += ["", strip_md(gk["order_note"]), ""]
    return "\n".join(lines)


def escape_applescript(text: str) -> str:
    return text.replace("\\", "\\\\").replace('"', '\\"')


def write_settings_webloc(path: Path) -> None:
    path.write_bytes(plistlib.dumps({"URL": SETTINGS_URL}, fmt=plistlib.FMT_BINARY))


def build_installer_app(locale: str) -> Path:
    ins = install_for(locale)
    app_name = ins["installer_app"]
    dest = OUT / locale / f"{app_name}.app"
    if dest.exists():
        shutil.rmtree(dest)

    script = APPLESCRIPT.read_text(encoding="utf-8")
    script = script.replace("__DIALOG_TITLE__", escape_applescript(ins["post_install_title"]))
    script = script.replace("__DIALOG_BODY__", escape_applescript(ins["post_install_body"]))
    script = script.replace(
        "__PRE_INSTALL_TITLE__",
        escape_applescript(ins.get("pre_install_title", INSTALL["en"]["pre_install_title"])),
    )
    script = script.replace(
        "__PRE_INSTALL_BODY__",
        escape_applescript(ins.get("pre_install_body", INSTALL["en"]["pre_install_body"])),
    )
    script = script.replace(
        "__CONTINUE_BUTTON__",
        escape_applescript(ins.get("continue_button", INSTALL["en"]["continue_button"])),
    )
    script = script.replace(
        "__OPEN_SETTINGS_BUTTON__",
        escape_applescript(ins.get("open_settings_button", INSTALL["en"]["open_settings_button"])),
    )
    script = script.replace(
        "__DISMISS_BUTTON__",
        escape_applescript(ins.get("dismiss_button", INSTALL["en"]["dismiss_button"])),
    )

    tmp_script = OUT / locale / ".install.applescript"
    tmp_script.parent.mkdir(parents=True, exist_ok=True)
    tmp_script.write_text(script, encoding="utf-8")

    subprocess.run(["osacompile", "-o", str(dest), str(tmp_script)], check=True)
    tmp_script.unlink(missing_ok=True)
    subprocess.run(
        ["codesign", "--force", "--deep", "--sign", "-", "--timestamp=none", str(dest)],
        check=True,
    )
    return dest


def main() -> None:
    locales = list(META["locales"].keys())
    for locale in locales:
        locale_dir = OUT / locale
        locale_dir.mkdir(parents=True, exist_ok=True)

        ins = install_for(locale)
        guide_path = locale_dir / ins["guide_file"]
        guide_path.write_text(build_guide(locale), encoding="utf-8")

        webloc_name = ins.get("settings_link_file", INSTALL["en"]["settings_link_file"])
        write_settings_webloc(locale_dir / webloc_name)

        app_path = build_installer_app(locale)
        print(f"  {locale}: {app_path.name}, {guide_path.name}, {webloc_name}")

    print(f"Generated DMG assets for {len(locales)} locales in {OUT}")


if __name__ == "__main__":
    main()
