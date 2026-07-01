#!/usr/bin/env python3
"""Generate non-technical README files for every supported locale."""

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
META = json.loads((ROOT / "scripts" / "languages-metadata.json").read_text(encoding="utf-8"))
GATEKEEPER = json.loads((ROOT / "scripts" / "gatekeeper-sections.json").read_text(encoding="utf-8"))
REPO = META["repo"]
VERSION = META["version"]
RELEASES = f"{REPO}/releases/latest"
DL = f"{REPO}/releases/download/v{VERSION}"

# Per-locale user-facing README content (non-technical)
CONTENT = {
    "zh-Hant": {
        "intro": "**專注時鐘**是一款免費、開源的 Mac 桌面應用。幫你設定一段專注時間（預設 25 分鐘），安靜做事；時間到了會提醒你，並記錄每天的成果。",
        "no_account": "不需要註冊帳號，不需要連網，所有資料都保存在你自己的 Mac 上。",
        "why_title": "好在哪裡？",
        "why": [
            "**打開就能用**：點「開始專注」即可",
            "**介面乾淨**：大圓環倒數、留白充足",
            "**時間靈活**：預設 25 分鐘，可 ±5 分鐘調整",
            "**隨時掌控**：支援暫停、繼續、提前結束",
            "**看見進步**：每完成一次種一棵樹 🌳，還有熱力圖",
            "**桌面寵物（可選）**：3000+ 像素夥伴，可下載、可浮窗常駐桌面",
            "**完全免費**：開源專案，程式碼公開",
        ],
        "pets_title": "桌面寵物（可選）",
        "pets_intro": "專注不必一個人硬撐。開啟桌面寵物後，可以：",
        "pets": [
            "**3000+ 像素圖鑑**：瀏覽、搜尋、下載喜歡的角色",
            "**專注時有回應**：寵物陪在計時器旁，表情隨狀態變化",
            "**桌面浮窗常駐**：把夥伴放在桌面上，切換應用也不離開",
            "**完全可選**：隨時關閉，不影響計時與統計",
        ],
        "use_title": "怎麼用？",
        "use_steps": [
            "下載並安裝應用",
            "在「應用程式」中開啟 **專注時鐘**",
            "點 **開始專注** 開始倒數",
            "結束後會收到完成提醒",
        ],
        "dl_title": "怎麼下載？",
        "chip_help": "蘋果選單 → **關於本機** → 看「晶片」或「處理器」",
        "apple_chip": "Apple 晶片（M 系列）",
        "intel_chip": "Intel 晶片",
        "dl_apple": "下載 Apple 晶片版",
        "dl_intel": "下載 Intel 版",
        "all_releases": "所有版本下載頁",
        "install_title": "安裝",
        "install": [
            "雙擊 `.dmg` 檔案",
            "將 **專注時鐘** 拖入「應用程式」",
            "推出磁碟映像後，從應用程式開啟",
        ],
        "faq_title": "常見問題",
        "faq": [
            ("需要連網嗎？", "不需要，完全在本機運行。"),
            ("資料存在哪？", "存在你的 Mac 本機，不會上傳。"),
            ("支援 Windows 嗎？", "目前僅支援 Mac（macOS 14.0+）。"),
        ],
        "about": "開源軟體，原始碼：",
    },
    "es": {
        "intro": "**Reloj de Enfoque** es una app gratuita y de código abierto para Mac. Te ayuda a concentrarte durante un tiempo (25 minutos por defecto) y registra tu progreso diario.",
        "no_account": "Sin registro ni conexión a internet. Tus datos permanecen en tu Mac.",
        "why_title": "¿Por qué te gustará?",
        "why": [
            "**Listo al instante**: abre y pulsa Iniciar enfoque",
            "**Diseño limpio**: gran anillo de progreso y mucho espacio",
            "**Tiempo flexible**: 25 min por defecto, ajustes de ±5 min",
            "**Control total**: pausa, reanuda o termina cuando quieras",
            "**Ve tu progreso**: un árbol 🌳 por sesión completada y mapa de calor",
            "**Mascotas de escritorio (opcional)**: 3000+ compañeros pixel, descargables y con ventana flotante",
            "**Totalmente gratis**: código abierto y transparente",
        ],
        "pets_title": "Mascotas de escritorio (opcional)",
        "pets_intro": "Enfocarte no tiene que ser solitario. Con las mascotas de escritorio puedes:",
        "pets": [
            "**Catálogo de 3000+**: explora, busca y descarga personajes",
            "**Reacciona al enfocarte**: acompaña en el temporizador y cambia expresión",
            "**Ventana flotante**: mantén tu compañero visible en el escritorio",
            "**Totalmente opcional**: desactívalo cuando quieras",
        ],
        "use_title": "Cómo usarlo",
        "use_steps": [
            "Descarga e instala la app",
            "Abre **Reloj de Enfoque** desde Aplicaciones",
            "Pulsa **Iniciar enfoque**",
            "Recibirás una notificación al terminar",
        ],
        "dl_title": "Cómo descargar",
        "chip_help": "Menú Apple → **Acerca de este Mac** → busca Chip o Procesador",
        "apple_chip": "Apple Silicon (serie M)",
        "intel_chip": "Intel",
        "dl_apple": "Descargar para Apple Silicon",
        "dl_intel": "Descargar para Intel",
        "all_releases": "Página de todas las versiones",
        "install_title": "Instalación",
        "install": [
            "Abre el archivo `.dmg`",
            "Arrastra **Reloj de Enfoque** a Aplicaciones",
            "Expulsa la imagen y abre la app",
        ],
        "faq_title": "Preguntas frecuentes",
        "faq": [
            ("¿Necesita internet?", "No, funciona completamente en local."),
            ("¿Dónde se guardan los datos?", "En tu Mac, sin subirlos a ningún servidor."),
            ("¿Windows o iPhone?", "Solo Mac, macOS 14.0 o posterior."),
        ],
        "about": "Software de código abierto:",
    },
    "fr": {
        "intro": "**Horloge Focus** est une application Mac gratuite et open source. Elle vous aide à vous concentrer (25 minutes par défaut) et enregistre vos progrès quotidiens.",
        "no_account": "Pas de compte, pas d'internet requis. Vos données restent sur votre Mac.",
        "why_title": "Pourquoi l'aimer ?",
        "why": [
            "**Prêt en un clic** : ouvrez et appuyez sur Démarrer la concentration",
            "**Interface épurée** : grand anneau de progression",
            "**Durée flexible** : 25 min par défaut, ±5 min",
            "**Contrôle total** : pause, reprise, fin anticipée",
            "**Suivez vos progrès** : un arbre 🌳 par session et carte de chaleur",
            "**Animaux de bureau (optionnel)** : 3000+ compagnons pixel, téléchargeables avec fenêtre flottante",
            "**Entièrement gratuit** : open source",
        ],
        "pets_title": "Animaux de bureau (optionnel)",
        "pets_intro": "Se concentrer n'a pas à être solitaire. Avec les animaux de bureau :",
        "pets": [
            "**Catalogue 3000+** : parcourez, recherchez et téléchargez",
            "**Réagit pendant le focus** : accompagne le minuteur",
            "**Fenêtre flottante** : visible sur le bureau",
            "**Entièrement optionnel** : désactivable à tout moment",
        ],
        "use_title": "Comment l'utiliser",
        "use_steps": [
            "Téléchargez et installez l'app",
            "Ouvrez **Horloge Focus** depuis Applications",
            "Appuyez sur **Démarrer la concentration**",
            "Une notification s'affiche à la fin",
        ],
        "dl_title": "Comment télécharger",
        "chip_help": "Menu Pomme → **À propos de ce Mac** → Puce ou Processeur",
        "apple_chip": "Apple Silicon (série M)",
        "intel_chip": "Intel",
        "dl_apple": "Télécharger pour Apple Silicon",
        "dl_intel": "Télécharger pour Intel",
        "all_releases": "Toutes les versions",
        "install_title": "Installation",
        "install": [
            "Ouvrez le fichier `.dmg`",
            "Glissez **Horloge Focus** dans Applications",
            "Éjectez l'image et lancez l'app",
        ],
        "faq_title": "FAQ",
        "faq": [
            ("Internet requis ?", "Non, tout fonctionne en local."),
            ("Où sont les données ?", "Sur votre Mac uniquement."),
            ("Windows ou iPhone ?", "Mac uniquement, macOS 14.0+."),
        ],
        "about": "Logiciel open source :",
    },
    "de": {
        "intro": "**Fokus-Uhr** ist eine kostenlose Open-Source-Mac-App. Sie hilft dir, dich zu konzentrieren (Standard 25 Minuten) und zeichnet deinen täglichen Fortschritt auf.",
        "no_account": "Kein Konto, kein Internet nötig. Alle Daten bleiben auf deinem Mac.",
        "why_title": "Das spricht dafür",
        "why": [
            "**Sofort startklar**: öffnen und Fokus starten",
            "**Klares Design**: großer Fortschrittsring",
            "**Flexible Zeit**: 25 Min. Standard, ±5 Min.",
            "**Volle Kontrolle**: Pause, Fortsetzen, vorzeitig beenden",
            "**Fortschritt sehen**: ein Baum 🌳 pro Session, Heatmap",
            "**Desktop-Haustiere (optional)**: 3000+ Pixel-Begleiter, downloadbar mit Schwebefenster",
            "**Komplett kostenlos**: Open Source",
        ],
        "pets_title": "Desktop-Haustiere (optional)",
        "pets_intro": "Fokussieren muss nicht einsam sein. Mit Desktop-Haustieren kannst du:",
        "pets": [
            "**3000+ Katalog**: durchsuchen, suchen und herunterladen",
            "**Reagiert beim Fokus**: begleitet den Timer",
            "**Schwebefenster**: auf dem Desktop sichtbar",
            "**Vollständig optional**: jederzeit abschaltbar",
        ],
        "use_title": "So funktioniert's",
        "use_steps": [
            "App herunterladen und installieren",
            "**Fokus-Uhr** aus Programme öffnen",
            "**Fokus starten** tippen",
            "Benachrichtigung bei Ende",
        ],
        "dl_title": "Download",
        "chip_help": "Apple-Menü → **Über diesen Mac** → Chip oder Prozessor",
        "apple_chip": "Apple Silicon (M-Serie)",
        "intel_chip": "Intel",
        "dl_apple": "Für Apple Silicon laden",
        "dl_intel": "Für Intel laden",
        "all_releases": "Alle Versionen",
        "install_title": "Installation",
        "install": [
            "`.dmg` öffnen",
            "**Fokus-Uhr** in Programme ziehen",
            "Image auswerfen und starten",
        ],
        "faq_title": "FAQ",
        "faq": [
            ("Internet nötig?", "Nein, läuft vollständig lokal."),
            ("Wo sind die Daten?", "Nur auf deinem Mac."),
            ("Windows oder iPhone?", "Nur Mac, macOS 14.0+."),
        ],
        "about": "Open-Source-Software:",
    },
}

# Fallback: use English structure with locale title for remaining langs
EN_FALLBACK = {
    "intro": "**{title}** is a free, open-source Mac focus timer. Set a session (default 25 min), work without distractions, and track your daily progress.",
    "no_account": "No account or internet required. All data stays on your Mac.",
    "why_title": "Why you'll like it",
    "why": [
        "**One tap to start**",
        "**Clean, calm design**",
        "**Flexible timing** (default 25 min)",
        "**Pause, resume, or end anytime**",
        "**Track progress** with trees 🌳 and a heatmap",
        "**Desktop pets (optional)** — 3000+ downloadable pixel companions with floating window",
        "**Completely free** and open source",
    ],
    "pets_title": "Desktop pets (optional)",
    "pets_intro": "Focus doesn't have to feel lonely. With desktop pets you can:",
    "pets": [
        "**Browse 3000+ companions** — search the catalog and download favorites",
        "**Get reactions while focusing** — your pet stays beside the timer",
        "**Float on your desktop** — keep your companion visible across apps",
        "**Turn off anytime** — the timer works perfectly on its own",
    ],
    "use_title": "How to use",
    "use_steps": [
        "Download and install",
        "Open **{title}** from Applications",
        "Tap **Start Focus**",
        "Get a notification when done",
    ],
    "dl_title": "Download",
    "chip_help": "Apple menu → **About This Mac** → Chip or Processor",
    "apple_chip": "Apple Silicon (M-series)",
    "intel_chip": "Intel",
    "dl_apple": "Download for Apple Silicon",
    "dl_intel": "Download for Intel",
    "all_releases": "All releases",
    "install_title": "Install",
    "install": [
        "Open the `.dmg` file",
        "Drag **{title}** to Applications",
        "Eject and launch the app",
    ],
    "faq_title": "FAQ",
    "faq": [
        ("Internet required?", "No, runs entirely on your Mac."),
        ("Where is data stored?", "Locally on your Mac only."),
        ("Windows or iPhone?", "Mac only, macOS 14.0+."),
    ],
    "about": "Open source:",
}

SKIP = {"zh-Hans", "en", "ja", "ko"}  # hand-maintained


def gatekeeper_for(locale: str) -> dict:
    if locale in GATEKEEPER:
        return GATEKEEPER[locale]
    return GATEKEEPER["en"]


def render_gatekeeper(locale: str) -> list[str]:
    g = gatekeeper_for(locale)
    lines = [
        "",
        f"### {g['title']}",
        "",
        g["intro"],
        "",
    ]
    for i, step in enumerate(g["steps"], 1):
        lines.append(f"{i}. {step}")
    lines += [
        "",
        f"> {g['order_note']}",
        "",
    ]
    return lines


def faq_gatekeeper(locale: str) -> tuple[str, str]:
    g = gatekeeper_for(locale)
    return g["faq_q"], g["faq_a"]


def other_lang_links(current: str) -> str:
    links = []
    for code, info in META["locales"].items():
        if code == current:
            continue
        if code in SKIP:
            path = f"README.{code}.md" if code != "zh-Hans" else "README.zh-Hans.md"
        else:
            path = f"README.{code}.md"
        links.append(f"[{info['label']}]({path})")
    links.append(f"[All languages](../README.md)")
    return " · ".join(links)


def render(locale: str, info: dict, c: dict) -> str:
    title = info["title"]
    c = {k: (v.format(title=title) if isinstance(v, str) else v) for k, v in c.items()}
    if locale not in SKIP:
        c["why"] = [x.format(title=title) if "{title}" in x else x for x in c["why"]]
        c["use_steps"] = [x.format(title=title) for x in c["use_steps"]]
        c["install"] = [x.format(title=title) for x in c["install"]]

    lines = [
        f"# {title}",
        "",
        other_lang_links(locale),
        "",
        c["intro"],
        "",
        c["no_account"],
        "",
        f"## {c['why_title']}",
        "",
    ]
    lines += [f"- {x}" for x in c["why"]]
    if c.get("pets"):
        lines += ["", f"## {c['pets_title']}", "", c["pets_intro"], ""]
        lines += [f"- {x}" for x in c["pets"]]
    lines += ["", f"## {c['use_title']}", ""]
    for i, step in enumerate(c["use_steps"], 1):
        lines.append(f"{i}. {step}")
    lines += [
        "",
        f"## {c['dl_title']}",
        "",
        f"**{c['chip_help']}**",
        "",
        f"| Chip | Download |",
        f"|------|----------|",
        f"| {c['apple_chip']} | [**{c['dl_apple']}**]({DL}/AttentionClock-{VERSION}-{locale}-arm64.dmg) |",
        f"| {c['intel_chip']} | [**{c['dl_intel']}**]({DL}/AttentionClock-{VERSION}-{locale}-x86_64.dmg) |",
        "",
        f"[{c['all_releases']}]({RELEASES})",
        "",
        f"## {c['install_title']}",
        "",
    ]
    for i, step in enumerate(c["install"], 1):
        lines.append(f"{i}. {step}")
    lines += render_gatekeeper(locale)
    lines += [
        f"## {c['faq_title']}",
        "",
    ]
    gq, ga = faq_gatekeeper(locale)
    lines.append(f"**{gq}**  ")
    lines.append(f"{ga}")
    lines.append("")
    for q, a in c["faq"]:
        lines.append(f"**{q}**  ")
        lines.append(f"{a}")
        lines.append("")
    lines += [f"## About", "", f"{c['about']} [{REPO.replace('https://', '')}]({REPO})", ""]
    return "\n".join(lines)


def main():
    docs = ROOT / "docs"
    docs.mkdir(exist_ok=True)
    for locale, info in META["locales"].items():
        if locale in SKIP:
            continue
        c = CONTENT.get(locale, EN_FALLBACK)
        path = docs / f"README.{locale}.md"
        path.write_text(render(locale, info, c), encoding="utf-8")
        print(f"Wrote {path}")


if __name__ == "__main__":
    main()
