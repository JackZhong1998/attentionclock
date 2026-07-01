#!/usr/bin/env python3
"""Generate per-locale DMG helper app and plain-text install guide."""

from __future__ import annotations

import json
import re
import shutil
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
GATEKEEPER = json.loads((ROOT / "scripts" / "gatekeeper-sections.json").read_text(encoding="utf-8"))
INSTALL = json.loads((ROOT / "scripts" / "dmg-install-sections.json").read_text(encoding="utf-8"))
DIALOG = json.loads((ROOT / "scripts" / "dmg-dialog-i18n.json").read_text(encoding="utf-8"))
META = json.loads((ROOT / "scripts" / "languages-metadata.json").read_text(encoding="utf-8"))
OUT = ROOT / "release" / "dmg-assets"
APPLESCRIPT = ROOT / "scripts" / "dmg" / "Install.applescript"
OPEN_SETTINGS_SCRIPT = ROOT / "scripts" / "dmg" / "OpenSettings.applescript"


def strip_md(text: str) -> str:
    return re.sub(r"\*\*([^*]+)\*\*", r"\1", text)


def install_for(locale: str) -> dict:
    base = {**INSTALL["en"], **INSTALL.get(locale, {})}
    dlg = DIALOG.get(locale, DIALOG["en"])
    base["pre_install_title"] = dlg["pre_install_title"]
    base["pre_install_body"] = dlg["pre_install_body"]
    base["post_install_title"] = dlg.get("post_install_title", DIALOG["en"]["post_install_title"])
    base["post_install_body"] = dlg.get("post_install_body", DIALOG["en"]["post_install_body"])
    return base


def gatekeeper_for(locale: str) -> dict:
    return GATEKEEPER.get(locale, GATEKEEPER["en"])


def build_guide(locale: str) -> str:
    ins = install_for(locale)
    gk = gatekeeper_for(locale)
    lines = [
        ins["guide_title"],
        "",
        ins["method1"],
        ins.get("settings_shortcut_line", ""),
        "",
    ]
    if gk.get("installer_steps"):
        lines += [strip_md(gk["installer_title"]), ""]
        for i, step in enumerate(gk["installer_steps"], 1):
            lines.append(f"{i}. {strip_md(step)}")
        lines.append("")
    lines += [strip_md(gk["title"]), ""]
    for i, step in enumerate(gk["steps"], 1):
        lines.append(f"{i}. {strip_md(step)}")
    lines.append("")
    return "\n".join(lines)


def escape_applescript(text: str) -> str:
    return text.replace("\\", "\\\\").replace('"', '\\"')


def build_settings_app(locale: str) -> Path:
    ins = install_for(locale)
    app_file = ins.get("settings_link_file", INSTALL["en"]["settings_link_file"])
    dest = OUT / locale / app_file
    if dest.exists():
        shutil.rmtree(dest)

    tmp_script = OUT / locale / ".open-settings.applescript"
    tmp_script.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy(OPEN_SETTINGS_SCRIPT, tmp_script)

    subprocess.run(["osacompile", "-o", str(dest), str(tmp_script)], check=True)
    tmp_script.unlink(missing_ok=True)
    subprocess.run(
        ["codesign", "--force", "--deep", "--sign", "-", "--timestamp=none", str(dest)],
        check=True,
    )
    return dest


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

        settings_app = build_settings_app(locale)
        app_path = build_installer_app(locale)
        print(f"  {locale}: {app_path.name}, {guide_path.name}, {settings_app.name}")

    print(f"Generated DMG assets for {len(locales)} locales in {OUT}")


if __name__ == "__main__":
    main()
