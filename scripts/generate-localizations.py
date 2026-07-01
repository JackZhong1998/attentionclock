#!/usr/bin/env python3
import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
LOCALIZABLE_PATH = ROOT / "AttentionClock" / "Localizable.xcstrings"
INFOPLIST_PATH = ROOT / "AttentionClock" / "InfoPlist.xcstrings"
LOCALES_DIR = ROOT / "scripts" / "locales"

BASE_LOCALES = ["en", "ja", "ko"]
NEW_LOCALES = [
    "zh-Hant",
    "es",
    "fr",
    "de",
    "pt-BR",
    "ru",
    "ar",
    "hi",
    "it",
    "th",
    "vi",
    "id",
    "tr",
    "nl",
    "pl",
    "uk",
    "ms",
]

DISPLAY_NAMES = {
    "zh-Hans": "专注时钟",
    "zh-Hant": "專注時鐘",
    "en": "Attention Clock",
    "es": "Reloj de Enfoque",
    "fr": "Horloge Focus",
    "de": "Fokus-Uhr",
    "ja": "集中タイマー",
    "ko": "집중 타이머",
    "pt-BR": "Relógio de Foco",
    "ru": "Часы Фокуса",
    "ar": "ساعة التركيز",
    "hi": "फोकस घड़ी",
    "it": "Orologio Focus",
    "th": "นาฬิกาโฟกัส",
    "vi": "Đồng Hồ Tập Trung",
    "id": "Jam Fokus",
    "tr": "Odak Saati",
    "nl": "Focus Klok",
    "pl": "Zegar Skupienia",
    "uk": "Годинник Фокусу",
    "ms": "Jam Fokus",
}

# Every key currently present in Localizable.xcstrings.
ALL_KEYS = [
    "%lld 分钟",
    "%lld 次",
    "%@：无专注记录",
    "%@\n%@ · 共 %@",
    "%d小时%d分",
    "%d分%d秒",
    "%d秒",
    "M月",
    "M月d日 EEEE",
    "yyyy年M月d日",
    "🌳 ×%lld",
    "一",
    "三",
    "二",
    "五",
    "六",
    "四",
    "日",
    "专注",
    "专注中",
    "专注完成",
    "专注完成，默契已提升",
    "专注热力图",
    "为你梦想蓄力一次",
    "为梦想蓄力一次",
    "今天",
    "今天你陪了我 %lld 分钟，好开心！",
    "今天状态不错～",
    "全部汇总",
    "共 %lld 次",
    "击退拖延一次",
    "夺回注意力一次",
    "虽然没完成，但也陪了我一会儿～",
    "含完成、暂停与提前结束",
    "基于 %lld 个活跃日",
    "多",
    "太好了！又一起专注啦",
    "好开心",
    "怎么停下来了？",
    "初识",
    "熟络",
    "恢复为默认时长",
    "拯救前额叶一次",
    "积攒实力一次",
    "日均次数",
    "日均时长",
    "平均每天专注时长",
    "已专注%lld分钟，%@",
    "已暂停",
    "开始",
    "开始专注",
    "所有记录合计",
    "好久没一起专注了",
    "小伴",
    "完成 %lld 次 %@",
    "完成次数",
    "对不起自己一次",
    "对得起自己一次",
    "少",
    "等你回来",
    "等你开始",
    "心流体验一次",
    "总时长",
    "本次时长",
    "默认时长",
    "默认时长会在每次专注结束后自动应用。打开应用后可直接点击「开始专注」，或先调整本次时长。",
    "未完成",
    "还没有完成的专注",
    "每完成一次种一棵树",
    "深度思考一次",
    "离目标更近一步",
    "暂停",
    "倒计时",
    "每日记录",
    "暂无记录，开始第一次专注吧",
    "状态不错",
    "陪伴中",
    "陪你专注中…",
    "点「开始专注」陪我吧",
    "版本",
    "默契 +1",
    "知道了",
    "统计",
    "继续",
    "累计完成",
    "累计时长",
    "结束",
    "设置",
    "过去 26 周每日专注情况，颜色越深表示越活跃",
    "安静地陪在你旁边…",
    "正在监督你",
    "准备开始",
    "热力图加载失败，请重启应用",
    "桌面浮窗",
    "桌面伙伴",
    "开启桌面伙伴",
    "开启桌面伙伴后，可从图鉴下载角色陪你专注，或显示在桌面上。",
    "搜索伙伴（支持中文/英文/日文等）",
    "从 Petdex 拉取最新伙伴列表",
    "没有匹配的伙伴，试试其他关键词或筛选条件。",
    "无法加载伙伴图鉴。",
    "图鉴已更新，新增 %lld 个伙伴，共 %lld 个。",
    "图鉴已是最新，共 %lld 个伙伴。",
    "伙伴包格式无效，无法安装。",
    "该伙伴已下载。",
    "高效成长一次",
]

# Keep format/day tokens locale-aware and deterministic (not machine-translated).
MANUAL_OVERRIDES = {
    "M月": {locale: "MMM" for locale in NEW_LOCALES},
    "M月d日 EEEE": {
        "zh-Hant": "M月d日 EEEE",
        "es": "d 'de' MMMM, EEEE",
        "fr": "d MMMM EEEE",
        "de": "EEEE, d. MMMM",
        "pt-BR": "d 'de' MMMM, EEEE",
        "ru": "d MMMM, EEEE",
        "ar": "d MMMM، EEEE",
        "hi": "d MMMM, EEEE",
        "it": "EEEE d MMMM",
        "th": "EEEE d MMMM",
        "vi": "EEEE, d MMMM",
        "id": "EEEE, d MMMM",
        "tr": "d MMMM EEEE",
        "nl": "EEEE d MMMM",
        "pl": "EEEE, d MMMM",
        "uk": "EEEE, d MMMM",
        "ms": "EEEE, d MMMM",
    },
    "yyyy年M月d日": {
        "zh-Hant": "yyyy年M月d日",
        "es": "d/M/yyyy",
        "fr": "dd/MM/yyyy",
        "de": "dd.MM.yyyy",
        "pt-BR": "dd/MM/yyyy",
        "ru": "dd.MM.yyyy",
        "ar": "d/M/yyyy",
        "hi": "dd/MM/yyyy",
        "it": "dd/MM/yyyy",
        "th": "d/M/yyyy",
        "vi": "d/M/yyyy",
        "id": "d/M/yyyy",
        "tr": "d.MM.yyyy",
        "nl": "d-M-yyyy",
        "pl": "dd.MM.yyyy",
        "uk": "dd.MM.yyyy",
        "ms": "d/M/yyyy",
    },
    "一": {"zh-Hant": "一", "es": "L", "fr": "L", "de": "M", "pt-BR": "S", "ru": "П", "ar": "ن", "hi": "सो", "it": "L", "th": "จ", "vi": "T2", "id": "S", "tr": "P", "nl": "M", "pl": "P", "uk": "П", "ms": "I"},
    "二": {"zh-Hant": "二", "es": "M", "fr": "M", "de": "D", "pt-BR": "T", "ru": "В", "ar": "ث", "hi": "मं", "it": "M", "th": "อ", "vi": "T3", "id": "S", "tr": "S", "nl": "D", "pl": "W", "uk": "В", "ms": "S"},
    "三": {"zh-Hant": "三", "es": "X", "fr": "M", "de": "M", "pt-BR": "Q", "ru": "С", "ar": "ر", "hi": "बु", "it": "M", "th": "พ", "vi": "T4", "id": "R", "tr": "Ç", "nl": "W", "pl": "Ś", "uk": "С", "ms": "R"},
    "四": {"zh-Hant": "四", "es": "J", "fr": "J", "de": "D", "pt-BR": "Q", "ru": "Ч", "ar": "خ", "hi": "गु", "it": "G", "th": "พฤ", "vi": "T5", "id": "K", "tr": "P", "nl": "D", "pl": "C", "uk": "Ч", "ms": "K"},
    "五": {"zh-Hant": "五", "es": "V", "fr": "V", "de": "F", "pt-BR": "S", "ru": "П", "ar": "ج", "hi": "शु", "it": "V", "th": "ศ", "vi": "T6", "id": "J", "tr": "C", "nl": "V", "pl": "P", "uk": "П", "ms": "J"},
    "六": {"zh-Hant": "六", "es": "S", "fr": "S", "de": "S", "pt-BR": "S", "ru": "С", "ar": "س", "hi": "श", "it": "S", "th": "ส", "vi": "T7", "id": "S", "tr": "C", "nl": "Z", "pl": "S", "uk": "С", "ms": "S"},
    "日": {"zh-Hant": "日", "es": "D", "fr": "D", "de": "S", "pt-BR": "D", "ru": "В", "ar": "ح", "hi": "र", "it": "D", "th": "อา", "vi": "CN", "id": "M", "tr": "P", "nl": "Z", "pl": "N", "uk": "Н", "ms": "A"},
}

TRADITIONAL_CHAR_MAP = str.maketrans(
    {
        "专": "專",
        "钟": "鐘",
        "时": "時",
        "长": "長",
        "图": "圖",
        "热": "熱",
        "猫": "貓",
        "粮": "糧",
        "为": "為",
        "云": "雲",
        "汇": "彙",
        "关": "關",
        "显": "顯",
        "击": "擊",
        "拖": "拖",
        "夺": "奪",
        "虽": "雖",
        "儿": "兒",
        "与": "與",
        "个": "個",
        "跃": "躍",
        "态": "態",
        "够": "夠",
        "吗": "嗎",
        "这": "這",
        "开": "開",
        "启": "啟",
        "将": "將",
        "放": "放",
        "喂": "餵",
        "会": "會",
        "总": "總",
        "记": "記",
        "积": "積",
        "续": "續",
        "过": "過",
        "颜": "顏",
        "色": "色",
        "静": "靜",
        "边": "邊",
        "载": "載",
        "请": "請",
        "重": "重",
        "设": "設",
        "统": "統",
        "毕": "畢",
        "后": "後",
        "还": "還",
        "种": "種",
        "吗": "嗎",
        "对": "對",
        "气": "氣",
        "没": "沒",
        "点": "點",
        "复": "復",
        "暂": "暫",
        "结": "結",
        "练": "練",
        "梦": "夢",
    }
)

def to_traditional(text: str) -> str:
    return text.translate(TRADITIONAL_CHAR_MAP)


def load_locale_translations():
    """
    Load scripts/locales/{locale}.json into a {key: {locale: value}} map.
    zh-Hant is intentionally excluded (generated by conversion/overrides).
    """
    translations = {key: {locale: None for locale in NEW_LOCALES} for key in ALL_KEYS}

    for locale in NEW_LOCALES:
        if locale == "zh-Hant":
            continue

        path = LOCALES_DIR / f"{locale}.json"
        if not path.exists():
            raise FileNotFoundError(f"Missing locale file: {path}")

        with path.open("r", encoding="utf-8") as f:
            locale_map = json.load(f)

        if not isinstance(locale_map, dict):
            raise ValueError(f"Locale file must be a JSON object: {path}")

        missing_keys = [key for key in ALL_KEYS if key not in locale_map]
        if missing_keys:
            raise ValueError(
                f"{path} missing {len(missing_keys)} keys, e.g. {missing_keys[:5]}"
            )

        for key in ALL_KEYS:
            value = locale_map.get(key)
            if not isinstance(value, str) or value == "":
                raise ValueError(
                    f"{path} has invalid translation for key '{key}': {value!r}"
                )
            translations[key][locale] = value

    return translations


def build_translations(existing_strings, translations):
    # Fill manual overrides first.
    for key, locale_map in MANUAL_OVERRIDES.items():
        for locale, value in locale_map.items():
            translations[key][locale] = value

    # zh-Hant uses deterministic conversion from source Chinese where not manually overridden.
    for key in ALL_KEYS:
        if translations[key]["zh-Hant"] is None:
            translations[key]["zh-Hant"] = to_traditional(key)

    # Ensure every key/locale pair is populated.
    for key in ALL_KEYS:
        for locale in NEW_LOCALES:
            if translations[key][locale] in (None, ""):
                raise ValueError(f"Missing translation for key '{key}' locale '{locale}'")


def write_localizable(existing_data):
    strings = existing_data.get("strings", {})
    existing_keys = list(strings.keys())
    translations = load_locale_translations()
    missing_in_script = [k for k in existing_keys if k not in translations]
    if missing_in_script:
        raise RuntimeError(f"Missing keys in TRANSLATIONS: {missing_in_script}")
    missing_in_file = [k for k in translations if k not in strings]
    if missing_in_file:
        raise RuntimeError(f"Keys not present in Localizable.xcstrings: {missing_in_file}")

    build_translations(strings, translations)

    output_strings = {}
    for key, entry in strings.items():
        output_entry = dict(entry)
        output_localizations = dict(output_entry.get("localizations", {}))

        for locale in NEW_LOCALES:
            output_localizations[locale] = {
                "stringUnit": {
                    "state": "translated",
                    "value": translations[key][locale],
                }
            }

        # Keep existing en/ja/ko as-is and preserve extractionState/metadata.
        output_entry["localizations"] = output_localizations
        output_strings[key] = output_entry

    output = {
        "sourceLanguage": existing_data.get("sourceLanguage", "zh-Hans"),
        "strings": output_strings,
        "version": existing_data.get("version", "1.0"),
    }

    with LOCALIZABLE_PATH.open("w", encoding="utf-8") as f:
        json.dump(output, f, ensure_ascii=False, indent=2)
        f.write("\n")


def write_info_plist():
    existing = {}
    if INFOPLIST_PATH.exists():
        with INFOPLIST_PATH.open("r", encoding="utf-8") as f:
            existing = json.load(f)

    strings = dict(existing.get("strings", {}))
    display_entry = dict(strings.get("CFBundleDisplayName", {}))
    localizations = dict(display_entry.get("localizations", {}))

    for locale, value in DISPLAY_NAMES.items():
        localizations[locale] = {
            "stringUnit": {
                "state": "translated",
                "value": value,
            }
        }

    display_entry["localizations"] = localizations
    strings["CFBundleDisplayName"] = display_entry

    output = {
        "sourceLanguage": existing.get("sourceLanguage", "zh-Hans"),
        "strings": strings,
        "version": existing.get("version", "1.0"),
    }

    with INFOPLIST_PATH.open("w", encoding="utf-8") as f:
        json.dump(output, f, ensure_ascii=False, indent=2)
        f.write("\n")


def main():
    with LOCALIZABLE_PATH.open("r", encoding="utf-8") as f:
        existing_data = json.load(f)

    write_localizable(existing_data)
    write_info_plist()

    print(f"Wrote: {LOCALIZABLE_PATH}")
    print(f"Wrote: {INFOPLIST_PATH}")


if __name__ == "__main__":
    main()
