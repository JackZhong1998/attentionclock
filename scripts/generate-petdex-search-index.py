#!/usr/bin/env python3
"""Generate bundled Petdex search index with multilingual aliases."""

import json
import re
import sys
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "AttentionClock/Resources/Petdex/petdex-index.json"

FRANCHISES = [
    {"id": "pokemon", "name": "宝可梦", "keywords": [
        "pokemon", "pokémon", "pikachu", "皮卡丘", "ピカチュウ", "snorlax", "卡比兽", "charizard", "喷火龙",
        "eevee", "伊布", "mewtwo", "超梦", "gengar", "耿鬼", "jigglypuff", "胖丁", "squirtle", "杰尼龟",
    ]},
    {"id": "lol", "name": "英雄联盟", "keywords": [
        "league of legends", "英雄联盟", "lol", "lux", "拉克丝", "ahri", "阿狸", "jinx", "金克丝", "yasuo", "亚索",
    ]},
    {"id": "jojo", "name": "JOJO的奇妙冒险", "keywords": [
        "jojo", "jotaro", "承太郎", "jolyne", "徐伦", "dio", "迪奥", "giorno", "乔鲁诺",
    ]},
    {"id": "genshin", "name": "原神", "keywords": [
        "genshin", "原神", "paimon", "派蒙", "zhongli", "钟离", "raiden", "雷电将军", "furina", "芙宁娜", "nahida", "纳西妲",
    ]},
    {"id": "naruto", "name": "火影忍者", "keywords": [
        "naruto", "火影忍者", "鸣人", "sasuke", "佐助", "kakashi", "卡卡西",
    ]},
    {"id": "onepiece", "name": "海贼王", "keywords": [
        "one piece", "海贼王", "luffy", "路飞", "zoro", "索隆", "chopper", "乔巴",
    ]},
    {"id": "zelda", "name": "塞尔达", "keywords": ["zelda", "塞尔达", "link", "林克", "hyrule"]},
    {"id": "mario", "name": "马里奥", "keywords": ["mario", "马里奥", "luigi", "路易吉", "bowser", "库巴", "yoshi", "耀西"]},
    {"id": "disney", "name": "迪士尼", "keywords": ["disney", "迪士尼", "mickey", "米奇", "stitch", "史迪奇", "elsa", "艾莎"]},
    {"id": "marvel", "name": "漫威", "keywords": ["marvel", "漫威", "spider-man", "蜘蛛侠", "iron man", "钢铁侠", "deadpool", "死侍"]},
    {"id": "dc", "name": "DC", "keywords": ["batman", "蝙蝠侠", "superman", "超人", "joker", "小丑"]},
    {"id": "sanrio", "name": "三丽鸥", "keywords": ["sanrio", "三丽鸥", "hello kitty", "凯蒂猫", "kuromi", "库洛米"]},
    {"id": "animal", "name": "动物", "keywords": ["cat", "猫", "dog", "狗", "penguin", "企鹅", "fox", "狐狸", "bear", "熊"]},
    {"id": "robot", "name": "机器人", "keywords": ["robot", "机器人", "mecha", "机甲", "tiko", "android"]},
]

KIND_LABELS = {
    "character": ["角色", "character", "キャラクター", "캐릭터", "personnage", "personaje"],
    "creature": ["生物", "creature", "クリーチャー", "생물", "créature", "criatura"],
    "object": ["物件", "object", "オブジェクト", "물건", "objet", "objeto"],
}

ALIASES_PATH = Path(__file__).resolve().parent / "pet-character-aliases.json"


def load_char_aliases() -> dict[str, list[str]]:
    if ALIASES_PATH.exists():
        return json.loads(ALIASES_PATH.read_text(encoding="utf-8"))
    return {}


CHAR_ALIASES = load_char_aliases()


def aliases_for_slug(slug: str, display: str) -> list[str]:
    hay = f"{slug} {display}".lower()
    slug_parts = set(re.split(r"[-_]", slug.lower()))
    result: list[str] = []
    for key, values in CHAR_ALIASES.items():
        if key in hay or key in slug_parts:
            result.extend(values)
    return result


def franchise_for(slug: str, display: str, kind: str) -> dict:
    hay = f"{display} {slug}".lower()
    for f in FRANCHISES:
        if any(k.lower() in hay for k in f["keywords"]):
            return f
    fallback = {
        "creature": {"id": "creature-kind", "name": "生物", "keywords": KIND_LABELS["creature"]},
        "object": {"id": "object-kind", "name": "物件", "keywords": KIND_LABELS["object"]},
        "character": {"id": "character-kind", "name": "原创角色", "keywords": KIND_LABELS["character"]},
    }
    return fallback.get(kind.lower(), {"id": "other", "name": "其他", "keywords": []})


def search_terms(slug: str, display: str, kind: str, franchise: dict) -> list[str]:
    terms = {slug.lower(), display.lower(), slug.replace("-", " ").lower()}
    for label in KIND_LABELS.get(kind.lower(), []):
        terms.add(label.lower())
    terms.add(franchise["name"].lower())
    hay = f"{display} {slug}".lower()
    for kw in franchise["keywords"]:
        if kw.lower() in hay:
            terms.add(kw.lower())
    for alias in aliases_for_slug(slug, display):
        terms.add(alias.lower())
    return sorted(t for t in terms if t)


def main() -> int:
    print("Fetching Petdex manifest...")
    req = urllib.request.Request(
        "https://petdex.dev/api/manifest",
        headers={"User-Agent": "AttentionClock/1.0"},
    )
    with urllib.request.urlopen(req, timeout=60) as resp:
        manifest = json.load(resp)

    entries = []
    for pet in manifest["pets"]:
        slug = pet["slug"]
        display = pet["displayName"]
        kind = pet.get("kind", "character")
        fr = franchise_for(slug, display, kind)
        entries.append({
            "slug": slug,
            "displayName": display,
            "kind": kind,
            "franchiseId": fr["id"],
            "franchiseName": fr["name"],
            "spritesheetUrl": pet["spritesheetUrl"],
            "petJsonUrl": pet["petJsonUrl"],
            "zipUrl": pet["zipUrl"],
            "searchTerms": search_terms(slug, display, kind, fr),
        })

    OUT.parent.mkdir(parents=True, exist_ok=True)
    payload = {
        "generatedAt": manifest.get("generatedAt"),
        "total": len(entries),
        "pets": entries,
    }
    OUT.write_text(json.dumps(payload, ensure_ascii=False, separators=(",", ":")), encoding="utf-8")
    print(f"Wrote {len(entries)} entries to {OUT} ({OUT.stat().st_size // 1024} KB)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
