#!/usr/bin/env python3
"""Add installer Gatekeeper fields to gatekeeper-sections.json for every locale."""

from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PATH = ROOT / "scripts" / "gatekeeper-sections.json"
INSTALL = json.loads((ROOT / "scripts" / "dmg-install-sections.json").read_text(encoding="utf-8"))

INSTALLER: dict[str, dict] = {
    "zh-Hans": {
        "installer_title": "「安装并打开」无法验证？",
        "installer_intro": "先放行安装助手，再安装应用。",
        "installer_steps": [
            "无法验证时点 **完成**",
            "系统设置 → **隐私与安全性** → 为 **安装并打开** 点 **仍要打开**",
            "再次双击 **安装并打开**",
        ],
        "installer_order_note": "先放行「安装并打开」，才会出现安装弹窗。",
        "title": "专注时钟提示「已损坏」？",
        "intro": "安装助手运行后，若拦截专注时钟：",
        "steps": [
            "点 **取消**（不要移到废纸篓）",
            "系统设置 → **仍要打开**（专注时钟）",
            "再次打开应用",
        ],
        "order_note": "须先触发一次拦截，「仍要打开」才会出现。",
        "faq_q": "安装或打开被拦截？",
        "faq_a": "先放行「安装并打开」，再放行专注时钟。",
    },
    "zh-Hant": {
        "installer_title": "「安裝並開啟」無法驗證？",
        "installer_intro": "先放行安裝助手。",
        "installer_steps": [
            "無法驗證時點 **完成**",
            "系統設定 → 為 **安裝並開啟** 點 **仍要打開**",
            "再次按兩下 **安裝並開啟**",
        ],
        "installer_order_note": "先放行安裝助手。",
        "title": "專注時鐘「已損壞」？",
        "intro": "安裝後若被攔截：",
        "steps": ["點 **取消**", "系統設定 → **仍要打開**", "再次開啟"],
        "order_note": "須先觸發一次攔截。",
        "faq_q": "被攔截？",
        "faq_a": "先放行安裝助手，再放行專注時鐘。",
    },
    "en": {
        "installer_title": "Cannot verify Install and Open?",
        "installer_intro": "Allow the installer first.",
        "installer_steps": [
            "Click **Done** if blocked",
            "System Settings → **Open Anyway** for **Install and Open**",
            "Double-click **Install and Open** again",
        ],
        "installer_order_note": "Allow the installer before the guide appears.",
        "title": "Attention Clock “damaged”?",
        "intro": "After install, if the app is blocked:",
        "steps": [
            "Click **Cancel**",
            "System Settings → **Open Anyway** for Attention Clock",
            "Open the app again",
        ],
        "order_note": "Trigger the block once first.",
        "faq_q": "Blocked?",
        "faq_a": "Allow Install and Open, then Attention Clock.",
    },
    "ja": {
        "installer_title": "「インストールして開く」を検証できない？",
        "installer_intro": "先に助手を許可してください。",
        "installer_steps": [
            "ブロック時は **完了**",
            "システム設定 → **このまま開く**（インストールして開く）",
            "もう一度ダブルクリック",
        ],
        "installer_order_note": "助手を先に許可。",
        "title": "「損傷しています」？",
        "intro": "インストール後にブロックされた場合：",
        "steps": ["**キャンセル**", "システム設定 → **このまま開く**", "再度開く"],
        "order_note": "先にブロックを1回起こす。",
        "faq_q": "ブロック？",
        "faq_a": "助手とアプリ、両方許可が必要な場合あり。",
    },
    "ko": {
        "installer_title": "「설치하고 열기」 확인 불가?",
        "installer_intro": "설치 도우미를 먼저 허용하세요.",
        "installer_steps": [
            "차단 시 **완료**",
            "시스템 설정 → **확인 없이 열기**（설치하고 열기）",
            "다시 더블 클릭",
        ],
        "installer_order_note": "도우미를 먼저 허용.",
        "title": "「손상됨」?",
        "intro": "설치 후 차단 시:",
        "steps": ["**취소**", "시스템 설정 → **확인 없이 열기**", "다시 열기"],
        "order_note": "먼저 차단을 한 번 발생.",
        "faq_q": "차단?",
        "faq_a": "도우미와 앱 각각 허용.",
    },
}


def installer_name(locale: str) -> str:
    return INSTALL.get(locale, INSTALL["en"])["installer_app"]


def patch_locale(locale: str, data: dict) -> dict:
    if locale in INSTALLER:
        return {**data, **INSTALLER[locale]}
    en = INSTALLER["en"].copy()
    name = installer_name(locale)
    en["installer_steps"] = [s.replace("Install and Open", name) for s in en["installer_steps"]]
    return {**data, **en}


def main() -> None:
    data = json.loads(PATH.read_text(encoding="utf-8"))
    for locale in list(data.keys()):
        data[locale] = patch_locale(locale, data[locale])
    PATH.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Patched {len(data)} locales in {PATH}")


if __name__ == "__main__":
    main()
