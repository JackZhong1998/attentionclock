#!/usr/bin/env python3
"""Rename 专注伙伴 → 桌面伙伴 across app localizations and marketing copy."""

from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LOCALIZABLE = ROOT / "AttentionClock" / "Localizable.xcstrings"
LOCALES_DIR = ROOT / "scripts" / "locales"
GEN_LOC = ROOT / "scripts" / "generate-localizations.py"
SITE_I18N = ROOT / "website" / "data" / "site-i18n.json"

KEY_RENAMES = {
    "专注伙伴": "桌面伙伴",
    "开启专注伙伴": "开启桌面伙伴",
    "开启专注伙伴后，可从图鉴下载角色陪你专注，或显示在桌面上。": (
        "开启桌面伙伴后，可从图鉴下载角色陪你专注，或显示在桌面上。"
    ),
}

NEW_TRANSLATIONS = {
    "桌面伙伴": {
        "en": "Desktop Companions",
        "ja": "デスクトップ相棒",
        "ko": "데스크톱 파트너",
        "es": "Compañeros de escritorio",
        "fr": "Compagnons de bureau",
        "de": "Desktop-Begleiter",
        "pt-BR": "Companheiros de desktop",
        "ru": "Настольные спутники",
        "ar": "رفقاء سطح المكتب",
        "hi": "डेस्कटॉप साथी",
        "it": "Compagni desktop",
        "th": "เพื่อนบนเดสก์ท็อป",
        "vi": "Bạn đồng hành desktop",
        "id": "Teman desktop",
        "tr": "Masaüstü arkadaşları",
        "nl": "Desktop-metgezellen",
        "pl": "Towarzysze na pulpicie",
        "uk": "Настільні супутники",
        "ms": "Rakan desktop",
    },
    "开启桌面伙伴": {
        "en": "Enable Desktop Companion",
        "ja": "デスクトップ相棒を有効にする",
        "ko": "데스크톱 파트너 사용",
        "es": "Activar compañero de escritorio",
        "fr": "Activer le compagnon de bureau",
        "de": "Desktop-Begleiter aktivieren",
        "pt-BR": "Ativar companheiro de desktop",
        "ru": "Включить настольного спутника",
        "ar": "تفعيل رفيق سطح المكتب",
        "hi": "डेस्कटॉप साथी चालू करें",
        "it": "Attiva compagno desktop",
        "th": "เปิดใช้เพื่อนบนเดสก์ท็อป",
        "vi": "Bật bạn đồng hành desktop",
        "id": "Aktifkan teman desktop",
        "tr": "Masaüstü arkadaşını etkinleştir",
        "nl": "Desktop-metgezel inschakelen",
        "pl": "Włącz towarzysza na pulpicie",
        "uk": "Увімкнути настільного супутника",
        "ms": "Dayakan rakan desktop",
    },
    "开启桌面伙伴后，可从图鉴下载角色陪你专注，或显示在桌面上。": {
        "en": "Enable desktop companions to download characters from the catalog, keep you company while focusing, or show one on your desktop.",
        "ja": "有効にすると、図鑑からキャラをダウンロードして集中を一緒にしたり、デスクトップに表示できます。",
        "ko": "켜면 도감에서 캐릭터를 받아 집중할 때 함께하거나 바탕화면에 표시할 수 있습니다.",
        "es": "Actívalo para descargar personajes del catálogo, acompañarte al enfocarte o mostrarlos en el escritorio.",
        "fr": "Activez pour télécharger des personnages, vous tenir compagnie pendant le focus ou les afficher sur le bureau.",
        "de": "Aktivieren, um Charaktere aus dem Katalog zu laden, beim Fokussieren Gesellschaft zu leisten oder sie auf dem Desktop anzuzeigen.",
        "pt-BR": "Ative para baixar personagens do catálogo, fazer companhia no foco ou exibir na área de trabalho.",
        "ru": "Включите, чтобы скачивать персонажей из каталога, сопровождать вас во время фокуса или показывать на рабочем столе.",
        "ar": "فعّل لتحميل الشخصيات من الفهرس، مرافقتك أثناء التركيز، أو عرضها على سطح المكتب.",
        "hi": "कैटलॉग से पात्र डाउनलोड करने, फ़ोकस में साथ देने या डेस्कटॉप पर दिखाने के लिए चालू करें।",
        "it": "Attiva per scaricare personaggi dal catalogo, farti compagnia durante il focus o mostrarli sul desktop.",
        "th": "เปิดใช้เพื่อดาวน์โหลดตัวละครจากคatalog คอยเป็นเพื่อนตอนโฟกัส หรือแสดงบนเดสก์ท็อป",
        "vi": "Bật để tải nhân vật từ danh mục, đồng hành khi tập trung hoặc hiển thị trên màn hình.",
        "id": "Aktifkan untuk mengunduh karakter dari katalog, menemani fokus, atau menampilkannya di desktop.",
        "tr": "Katalogdan karakter indirmek, odaklanırken eşlik etmek veya masaüstünde göstermek için etkinleştirin.",
        "nl": "Schakel in om personages uit de catalogus te downloaden, gezelschap te houden tijdens focus of op het bureaublad te tonen.",
        "pl": "Włącz, aby pobierać postacie z katalogu, towarzyszyć podczas skupienia lub wyświetlać na pulpicie.",
        "uk": "Увімкніть, щоб завантажувати персонажів із каталогу, супроводжувати під час фокусу або показувати на робочому столі.",
        "ms": "Dayakan untuk memuat turun watak dari katalog, menemani fokus, atau paparkan di desktop.",
    },
}

TRAD_MAP = str.maketrans(
    {
        "专": "專",
        "时": "時",
        "开": "開",
        "启": "啟",
        "从": "從",
        "图": "圖",
        "鉴": "鑑",
        "载": "載",
        "显": "顯",
        "面": "面",
        "伙": "夥",
        "伴": "伴",
        "后": "後",
        "专": "專",
        "注": "注",
        "或": "或",
        "角": "角",
        "色": "色",
        "陪": "陪",
        "你": "你",
        "焦": "焦",
        "在": "在",
        "桌": "桌",
        "上": "上",
        "。" : "。",
    }
)


def to_traditional(text: str) -> str:
    return text.translate(TRAD_MAP)


def migrate_xcstrings() -> None:
    data = json.loads(LOCALIZABLE.read_text(encoding="utf-8"))
    strings = data["strings"]
    for old, new in KEY_RENAMES.items():
        if old in strings:
            strings[new] = strings.pop(old)
    for key, locale_map in NEW_TRANSLATIONS.items():
        locs = {
            "zh-Hans": {"stringUnit": {"state": "translated", "value": key}},
            "zh-Hant": {"stringUnit": {"state": "translated", "value": to_traditional(key)}},
        }
        for locale, value in locale_map.items():
            locs[locale] = {"stringUnit": {"state": "translated", "value": value}}
        strings[key] = {"localizations": locs}
    data["strings"] = strings
    LOCALIZABLE.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def migrate_locales() -> None:
    for path in LOCALES_DIR.glob("*.json"):
        locale = path.stem
        data = json.loads(path.read_text(encoding="utf-8"))
        for old in KEY_RENAMES:
            data.pop(old, None)
        for key, translations in NEW_TRANSLATIONS.items():
            if locale in translations:
                data[key] = translations[locale]
        path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def migrate_gen_loc() -> None:
    text = GEN_LOC.read_text(encoding="utf-8")
    for old, new in KEY_RENAMES.items():
        text = text.replace(f'"{old}"', f'"{new}"')
    GEN_LOC.write_text(text, encoding="utf-8")


def migrate_site_i18n() -> None:
    data = json.loads(SITE_I18N.read_text(encoding="utf-8"))

    zh_hans = {
        "meta_description": "专注时钟是免费 Mac 专注计时器，内置 3000+ 可下载桌面伙伴。番茄钟专注、热力图统计、像素角色桌面浮窗。无需注册，数据本地保存。",
        "meta_keywords": "专注计时, 桌面伙伴, Mac 伙伴, 番茄钟, Mac 效率, 专注时钟, 开源, 像素角色",
        "hero_lead": "安静的 Mac 专注计时器，还可选桌面伙伴陪你一起做事。从 3000+ 像素角色中挑选，放到桌面上，专注也更有动力。",
        "f6_title": "3000+ 桌面伙伴",
        "f6_desc": "浏览角色图鉴、搜索下载、随时切换你的桌面伙伴。",
        "tab2_title": "桌面伙伴",
        "tab2_desc": "浏览、下载和管理像素桌面伙伴。",
        "nav_pets": "桌面伙伴",
        "meta_pets": "3000+ 桌面伙伴",
        "pets_title": "桌面伙伴，陪你一起专注",
        "pets_sub": "可选、轻量、却意外有动力——专注不必一个人硬撑。",
        "pet1_desc": "3000+ 角色任你选——同人 IP、游戏角色、小动物等。支持搜索和筛选，找到最合眼缘的那位。",
        "pet2_desc": "专注过程中伙伴会陪在身边，表情随状态变化，完成时还会庆祝。",
        "faq5_q": "桌面伙伴需要联网吗？",
        "faq5_a": "浏览和下载新伙伴时需要网络。专注计时和统计可完全离线使用。",
        "footer_tagline": "带桌面伙伴的免费 Mac 专注计时器。坐下来，专注，带个伙伴。",
    }
    zh_hant = {k: to_traditional(v) if k != "meta_keywords" else "專注計時, 桌面夥伴, Mac 夥伴, 番茄鐘, Mac 效率, 專注時鐘, 開源, 像素角色" for k, v in zh_hans.items()}
    en = {
        "meta_description": "Attention Clock is a free Mac focus timer with 3000+ downloadable desktop companions. Pomodoro sessions, heatmap stats, floating pixel characters. No account, data stays local.",
        "meta_keywords": "focus timer, desktop companion, mac desktop buddy, pomodoro, mac productivity, attention clock, open source, pixel character",
        "hero_lead": "A calm Mac focus timer with optional desktop companions. Pick a pixel character from 3000+ options, float it on your desktop, and stay motivated while you work.",
        "f6_title": "3000+ desktop companions",
        "f6_desc": "Browse the catalog, search characters, download favorites, and switch companions anytime.",
        "tab2_title": "Desktop Companions",
        "tab2_desc": "Browse, download, and manage pixel desktop companions.",
        "nav_pets": "Desktop Companions",
        "meta_pets": "3000+ desktop companions",
        "pets_title": "Desktop companions by your side",
        "pets_sub": "Optional, lightweight, and surprisingly motivating — you don't have to focus alone.",
        "pet1_desc": "Browse 3000+ companions — characters, creatures, and more. Search and filter to find your favorite.",
        "pet2_desc": "Your companion stays with you during sessions, changes expression, and celebrates when you finish.",
        "faq5_q": "Do desktop companions need the internet?",
        "faq5_a": "Only to browse and download new companions. Focus timing and stats work fully offline.",
        "footer_tagline": "Free Mac focus timer with optional desktop companions. Sit down, focus, bring someone along.",
    }
    ja = {
        "meta_description": "集中タイマーは無料の Mac 集中タイマー。3000体以上のダウンロード可能なデスクトップ相棒、ポモドーロ、ヒートマップ、ピクセルキャラの浮窗付き。",
        "hero_lead": "静かな Mac 集中タイマーに、任意のデスクトップ相棒を。3000体以上のピクセルキャラから選んでデスクトップに置き、集中を後押し。",
        "f6_title": "3000+ デスクトップ相棒",
        "tab2_title": "デスクトップ相棒",
        "nav_pets": "デスクトップ相棒",
        "meta_pets": "3000+ 相棒",
        "pets_title": "デスクトップ相棒がそばにいる",
        "faq5_q": "デスクトップ相棒にインターネットは必要？",
        "footer_tagline": "デスクトップ相棒付きの無料 Mac 集中タイマー。",
    }
    ko = {
        "meta_description": "집중 타이머는 3000개 이상의 다운로드 가능한 데스크톱 파트너가 있는 무료 Mac 집중 타이머입니다.",
        "hero_lead": "조용한 Mac 집중 타이머에 선택적인 데스크톱 파트너를 더하세요. 3000개 이상의 픽셀 캐릭터 중 골라 바탕화면에 두고 집중하세요.",
        "f6_title": "3000+ 데스크톱 파트너",
        "tab2_title": "데스크톱 파트너",
        "nav_pets": "데스크톱 파트너",
        "meta_pets": "3000+ 동반자",
        "pets_title": "데스크톱 파트너가 곁에",
        "faq5_q": "데스크톱 파트너에 인터넷이 필요한가요?",
        "footer_tagline": "데스크톱 파트너가 있는 무료 Mac 집중 타이머.",
    }

    for locale, overrides in [("zh-Hans", zh_hans), ("zh-Hant", zh_hant), ("en", en), ("ja", ja), ("ko", ko)]:
        data[locale].update(overrides)

    for locale, block in data.items():
        if locale in {"zh-Hans", "zh-Hant", "en", "ja", "ko"}:
            continue
        for key, val in list(block.items()):
            if not isinstance(val, str):
                continue
            val = re.sub(r"(?i)focus companions?", "desktop companions", val)
            val = re.sub(r"(?i)focus companion", "desktop companion", val)
            val = re.sub(r"专注伙伴", "桌面伙伴", val)
            block[key] = val

    SITE_I18N.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def replace_in_file(path: Path, pairs: list[tuple[str, str]]) -> None:
    if not path.exists():
        return
    text = path.read_text(encoding="utf-8")
    orig = text
    for old, new in pairs:
        text = text.replace(old, new)
    if text != orig:
        path.write_text(text, encoding="utf-8")


def migrate_markdown_and_swift() -> None:
    pairs_zh = [
        ("专注伙伴", "桌面伙伴"),
        ("專注夥伴", "桌面夥伴"),
        ("像素专注伙伴", "像素桌面伙伴"),
        ("像素專注夥伴", "像素桌面夥伴"),
        ("focus companions", "desktop companions"),
        ("Focus companions", "Desktop companions"),
        ("focus companion", "desktop companion"),
        ("Focus companion", "Desktop companion"),
        ("Companions tab", "Desktop Companions tab"),
        ("**Companions**", "**Desktop Companions**"),
        ("集中パートナー", "デスクトップ相棒"),
        ("집중 파트너", "데스크톱 파트너"),
        ("Compañeros de enfoque", "Compañeros de escritorio"),
        ("Compagnons de focus", "Compagnons de bureau"),
        ("Fokus-Begleiter", "Desktop-Begleiter"),
    ]
    files = [
        ROOT / "README.md",
        ROOT / "docs" / "README.zh-Hans.md",
        ROOT / "docs" / "README.en.md",
        ROOT / "docs" / "README.ja.md",
        ROOT / "docs" / "README.ko.md",
        ROOT / "docs" / "README.zh-Hant.md",
        ROOT / "scripts" / "generate-readmes.py",
        ROOT / "AttentionClock" / "ContentView.swift",
        ROOT / "AttentionClock" / "Views" / "DesktopPetView.swift",
    ]
    for f in files:
        replace_in_file(f, pairs_zh)


def main() -> None:
    migrate_xcstrings()
    migrate_locales()
    migrate_gen_loc()
    migrate_site_i18n()
    migrate_markdown_and_swift()
    print("Done: 专注伙伴 → 桌面伙伴")


if __name__ == "__main__":
    main()
