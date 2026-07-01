#!/usr/bin/env python3
"""One-time migration: cat-raising copy → light focus companion terminology."""

from __future__ import annotations

import json
import re
from copy import deepcopy
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LOCALIZABLE = ROOT / "AttentionClock" / "Localizable.xcstrings"
LOCALES_DIR = ROOT / "scripts" / "locales"
GEN_LOC = ROOT / "scripts" / "generate-localizations.py"
SITE_I18N = ROOT / "website" / "data" / "site-i18n.json"

# old zh-Hans key -> new zh-Hans key
KEY_RENAMES = {
    "专注完成，猫粮已领取": "专注完成，默契已提升",
    "好棒！吃到猫粮啦": "太好了！又一起专注啦",
    "幼猫": "初识",
    "成猫": "熟络",
    "喵…好久没陪我啦": "好久没一起专注了",
    "咪咪": "小伴",
    "猫粮 +1": "默契 +1",
    "安静地趴在你旁边…": "安静地陪在你旁边…",
}

REMOVE_KEYS = {
    "云养猫",
    "开始云养猫",
    "喵喵…好久没陪我啦",
    "关闭后不显示任何养猫相关功能。",
    "开启后会有像素小猫陪伴专注；桌面浮窗可将小猫放在桌面上。",
}

NEW_KEYS = {
    "专注伙伴": {
        "en": "Companions",
        "ja": "集中パートナー",
        "ko": "집중 파트너",
        "es": "Compañeros",
        "fr": "Compagnons",
        "de": "Begleiter",
        "pt-BR": "Companheiros",
        "ru": "Спутники",
        "ar": "الرفاق",
        "hi": "साथी",
        "it": "Compagni",
        "th": "เพื่อนร่วมทาง",
        "vi": "Bạn đồng hành",
        "id": "Teman fokus",
        "tr": "Yol arkadaşları",
        "nl": "Metgezellen",
        "pl": "Towarzysze",
        "uk": "Супутники",
        "ms": "Rakan fokus",
    },
    "开启专注伙伴": {
        "en": "Enable Focus Companion",
        "ja": "集中パートナーを有効にする",
        "ko": "집중 파트너 사용",
        "es": "Activar compañero de enfoque",
        "fr": "Activer le compagnon de focus",
        "de": "Fokus-Begleiter aktivieren",
        "pt-BR": "Ativar companheiro de foco",
        "ru": "Включить спутника фокуса",
        "ar": "تفعيل رفيق التركيز",
        "hi": "फ़ोकस साथी चालू करें",
        "it": "Attiva compagno di focus",
        "th": "เปิดใช้เพื่อนร่วมโฟกัส",
        "vi": "Bật bạn đồng hành tập trung",
        "id": "Aktifkan teman fokus",
        "tr": "Odak arkadaşını etkinleştir",
        "nl": "Focus-metgezel inschakelen",
        "pl": "Włącz towarzysza skupienia",
        "uk": "Увімкнути супутника фокусу",
        "ms": "Dayakan rakan fokus",
    },
    "开启专注伙伴后，可从图鉴下载角色陪你专注，或显示在桌面上。": {
        "en": "Enable companions to download characters from the catalog, keep you company while focusing, or show one on your desktop.",
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
    "搜索伙伴（支持中文/英文/日文等）": {
        "en": "Search companions (Chinese, English, Japanese…)",
        "ja": "パートナーを検索（中国語・英語・日本語など）",
        "ko": "동반자 검색 (중국어/영어/일본어 등)",
        "es": "Buscar compañeros (chino, inglés, japonés…)",
        "fr": "Rechercher des compagnons (chinois, anglais, japonais…)",
        "de": "Begleiter suchen (Chinesisch, Englisch, Japanisch…)",
        "pt-BR": "Buscar companheiros (chinês, inglês, japonês…)",
        "ru": "Поиск спутников (китайский, английский, японский…)",
        "ar": "البحث عن الرفاق (صيني، إنجليزي، ياباني…)",
        "hi": "साथी खोजें (चीनी, अंग्रेज़ी, जापानी…)",
        "it": "Cerca compagni (cinese, inglese, giapponese…)",
        "th": "ค้นหาเพื่อนร่วมทาง (จีน อังกฤษ ญี่ปุ่น ฯลฯ)",
        "vi": "Tìm bạn đồng hành (tiếng Trung, Anh, Nhật…)",
        "id": "Cari teman (Mandarin, Inggris, Jepang…)",
        "tr": "Yol arkadaşı ara (Çince, İngilizce, Japonca…)",
        "nl": "Metgezellen zoeken (Chinees, Engels, Japans…)",
        "pl": "Szukaj towarzyszy (chiński, angielski, japoński…)",
        "uk": "Пошук супутників (китайська, англійська, японська…)",
        "ms": "Cari rakan (Cina, Inggeris, Jepun…)",
    },
    "从 Petdex 拉取最新伙伴列表": {
        "en": "Fetch the latest companion list from Petdex",
        "ja": "Petdex から最新のパートナー一覧を取得",
        "ko": "Petdex에서 최신 동반자 목록 가져오기",
        "es": "Obtener la lista más reciente de compañeros desde Petdex",
        "fr": "Récupérer la liste des compagnons depuis Petdex",
        "de": "Neueste Begleiterliste von Petdex abrufen",
        "pt-BR": "Buscar a lista mais recente de companheiros no Petdex",
        "ru": "Загрузить актуальный список спутников из Petdex",
        "ar": "جلب أحدث قائمة رفاق من Petdex",
        "hi": "Petdex से नवीनतम साथी सूची लाएँ",
        "it": "Recupera l'elenco aggiornato dei compagni da Petdex",
        "th": "ดึงรายชื่อเพื่อนล่าสุดจาก Petdex",
        "vi": "Lấy danh sách bạn đồng hành mới nhất từ Petdex",
        "id": "Ambil daftar teman terbaru dari Petdex",
        "tr": "Petdex'ten en son yol arkadaşı listesini al",
        "nl": "Haal de nieuwste metgezellenlijst op van Petdex",
        "pl": "Pobierz najnowszą listę towarzyszy z Petdex",
        "uk": "Отримати останній список супутників з Petdex",
        "ms": "Ambil senarai rakan terkini dari Petdex",
    },
    "没有匹配的伙伴，试试其他关键词或筛选条件。": {
        "en": "No matching companions — try other keywords or filters.",
        "ja": "一致するパートナーがありません。別のキーワードやフィルターをお試しください。",
        "ko": "일치하는 동반자가 없습니다. 다른 키워드나 필터를 시도해 보세요.",
        "es": "Sin coincidencias — prueba otras palabras clave o filtros.",
        "fr": "Aucun compagnon trouvé — essayez d'autres mots-clés ou filtres.",
        "de": "Keine passenden Begleiter — andere Suchbegriffe oder Filter versuchen.",
        "pt-BR": "Nenhum companheiro encontrado — tente outras palavras-chave ou filtros.",
        "ru": "Совпадений нет — попробуйте другие ключевые слова или фильтры.",
        "ar": "لا يوجد رفاق مطابقون — جرّب كلمات مفتاحية أو فلاتر أخرى.",
        "hi": "कोई मेल खाता साथी नहीं — अन्य कीवर्ड या फ़िल्टर आज़माएँ।",
        "it": "Nessun compagno corrispondente — prova altre parole chiave o filtri.",
        "th": "ไม่พบเพื่อนที่ตรงกัน ลองคำค้นหาหรือตัวกรองอื่น",
        "vi": "Không có bạn đồng hành phù hợp — thử từ khóa hoặc bộ lọc khác.",
        "id": "Tidak ada teman yang cocok — coba kata kunci atau filter lain.",
        "tr": "Eşleşen yol arkadaşı yok — başka anahtar kelimeler veya filtreler deneyin.",
        "nl": "Geen overeenkomende metgezellen — probeer andere zoekwoorden of filters.",
        "pl": "Brak pasujących towarzyszy — spróbuj innych słów kluczowych lub filtrów.",
        "uk": "Супутників не знайдено — спробуйте інші ключові слова або фільтри.",
        "ms": "Tiada rakan sepadan — cuba kata kunci atau penapis lain.",
    },
    "无法加载伙伴图鉴。": {
        "en": "Couldn't load the companion catalog.",
        "ja": "パートナー図鑑を読み込めませんでした。",
        "ko": "동반자 도감을 불러올 수 없습니다.",
        "es": "No se pudo cargar el catálogo de compañeros.",
        "fr": "Impossible de charger le catalogue des compagnons.",
        "de": "Begleiter-Katalog konnte nicht geladen werden.",
        "pt-BR": "Não foi possível carregar o catálogo de companheiros.",
        "ru": "Не удалось загрузить каталог спутников.",
        "ar": "تعذّر تحميل فهرس الرفاق.",
        "hi": "साथी कैटलॉग लोड नहीं हो सका।",
        "it": "Impossibile caricare il catalogo dei compagni.",
        "th": "โหลดคatalog เพื่อนร่วมทางไม่ได้",
        "vi": "Không thể tải danh mục bạn đồng hành.",
        "id": "Tidak dapat memuat katalog teman.",
        "tr": "Yol arkadaşı kataloğu yüklenemedi.",
        "nl": "Metgezellen-catalogus kon niet worden geladen.",
        "pl": "Nie udało się wczytać katalogu towarzyszy.",
        "uk": "Не вдалося завантажити каталог супутників.",
        "ms": "Tidak dapat memuatkan katalog rakan.",
    },
    "图鉴已更新，新增 %lld 个伙伴，共 %lld 个。": {
        "en": "Catalog updated — %lld new companions (%lld total).",
        "ja": "図鑑を更新しました。新規 %lld 体、合計 %lld 体。",
        "ko": "도감 업데이트 — 새 동반자 %lld명 (총 %lld명).",
        "es": "Catálogo actualizado — %lld compañeros nuevos (%lld en total).",
        "fr": "Catalogue mis à jour — %lld nouveaux compagnons (%lld au total).",
        "de": "Katalog aktualisiert — %lld neue Begleiter (%lld gesamt).",
        "pt-BR": "Catálogo atualizado — %lld novos companheiros (%lld no total).",
        "ru": "Каталог обновлён — %lld новых спутников (всего %lld).",
        "ar": "تم تحديث الفهرس — %lld رفيق جديد (%lld إجمالاً).",
        "hi": "कैटलॉग अपडेट — %lld नए साथी (कुल %lld)।",
        "it": "Catalogo aggiornato — %lld nuovi compagni (%lld totali).",
        "th": "อัปเดตคatalog แล้ว — เพิ่ม %lld ราย (รวม %lld)",
        "vi": "Đã cập nhật danh mục — %lld bạn mới (tổng %lld).",
        "id": "Katalog diperbarui — %lld teman baru (total %lld).",
        "tr": "Katalog güncellendi — %lld yeni yol arkadaşı (toplam %lld).",
        "nl": "Catalogus bijgewerkt — %lld nieuwe metgezellen (%lld totaal).",
        "pl": "Katalog zaktualizowany — %lld nowych towarzyszy (łącznie %lld).",
        "uk": "Каталог оновлено — %lld нових супутників (усього %lld).",
        "ms": "Katalog dikemas kini — %lld rakan baharu (jumlah %lld).",
    },
    "图鉴已是最新，共 %lld 个伙伴。": {
        "en": "Catalog is up to date — %lld companions.",
        "ja": "図鑑は最新です（合計 %lld 体）。",
        "ko": "도감이 최신입니다 — 총 %lld명.",
        "es": "El catálogo está actualizado — %lld compañeros.",
        "fr": "Le catalogue est à jour — %lld compagnons.",
        "de": "Katalog ist aktuell — %lld Begleiter.",
        "pt-BR": "Catálogo atualizado — %lld companheiros.",
        "ru": "Каталог актуален — %lld спутников.",
        "ar": "الفهرس محدّث — %lld رفيق.",
        "hi": "कैटलॉग अद्यतन है — %lld साथी।",
        "it": "Catalogo aggiornato — %lld compagni.",
        "th": "คatalog ล่าสุดแล้ว — รวม %lld ราย",
        "vi": "Danh mục đã cập nhật — %lld bạn đồng hành.",
        "id": "Katalog sudah terbaru — %lld teman.",
        "tr": "Katalog güncel — %lld yol arkadaşı.",
        "nl": "Catalogus is up-to-date — %lld metgezellen.",
        "pl": "Katalog jest aktualny — %lld towarzyszy.",
        "uk": "Каталог актуальний — %lld супутників.",
        "ms": "Katalog terkini — %lld rakan.",
    },
    "伙伴包格式无效，无法安装。": {
        "en": "Invalid companion pack — can't install.",
        "ja": "パートナーパックの形式が無効で、インストールできません。",
        "ko": "동반자 팩 형식이 올바르지 않아 설치할 수 없습니다.",
        "es": "Paquete de compañero no válido — no se puede instalar.",
        "fr": "Pack compagnon invalide — installation impossible.",
        "de": "Ungültiges Begleiter-Paket — Installation nicht möglich.",
        "pt-BR": "Pacote de companheiro inválido — não é possível instalar.",
        "ru": "Неверный пакет спутника — установка невозможна.",
        "ar": "حزمة الرفيق غير صالحة — لا يمكن التثبيت.",
        "hi": "अमान्य साथी पैक — इंस्टॉल नहीं हो सकता।",
        "it": "Pacchetto compagno non valido — impossibile installare.",
        "th": "แพ็กเพื่อนร่วมทางไม่ถูกต้อง ติดตั้งไม่ได้",
        "vi": "Gói bạn đồng hành không hợp lệ — không thể cài đặt.",
        "id": "Paket teman tidak valid — tidak dapat diinstal.",
        "tr": "Geçersiz yol arkadaşı paketi — yüklenemiyor.",
        "nl": "Ongeldig metgezellenpakket — kan niet installeren.",
        "pl": "Nieprawidłowa paczka towarzysza — nie można zainstalować.",
        "uk": "Недійсний пакет супутника — неможливо встановити.",
        "ms": "Pakej rakan tidak sah — tidak boleh dipasang.",
    },
    "该伙伴已下载。": {
        "en": "This companion is already downloaded.",
        "ja": "このパートナーはすでにダウンロード済みです。",
        "ko": "이 동반자는 이미 다운로드되었습니다.",
        "es": "Este compañero ya está descargado.",
        "fr": "Ce compagnon est déjà téléchargé.",
        "de": "Dieser Begleiter ist bereits heruntergeladen.",
        "pt-BR": "Este companheiro já foi baixado.",
        "ru": "Этот спутник уже загружен.",
        "ar": "تم تنزيل هذا الرفيق بالفعل.",
        "hi": "यह साथी पहले से डाउनलोड है।",
        "it": "Questo compagno è già stato scaricato.",
        "th": "ดาวน์โหลดเพื่อนรายนี้แล้ว",
        "vi": "Bạn đồng hành này đã được tải.",
        "id": "Teman ini sudah diunduh.",
        "tr": "Bu yol arkadaşı zaten indirildi.",
        "nl": "Deze metgezel is al gedownload.",
        "pl": "Ten towarzysz jest już pobrany.",
        "uk": "Цього супутника вже завантажено.",
        "ms": "Rakan ini sudah dimuat turun.",
    },
}

RENAMED_TRANSLATIONS = {
    "专注完成，默契已提升": {
        "en": "Focus complete — bond strengthened",
        "ja": "集中完了 — 絆が深まりました",
        "ko": "집중 완료 — 유대감 상승",
        "es": "Enfoque completado — vínculo reforzado",
        "fr": "Focus terminé — lien renforcé",
        "de": "Fokus abgeschlossen — Bindung gestärkt",
        "pt-BR": "Foco concluído — vínculo fortalecido",
        "ru": "Фокус завершён — связь укреплена",
        "ar": "اكتمل التركيز — تعزّزت الرابطة",
        "hi": "फ़ोकस पूरा — बंधन मज़बूत हुआ",
        "it": "Focus completato — legame rafforzato",
        "th": "โฟกัสเสร็จแล้ว — ความผูกพันเพิ่มขึ้น",
        "vi": "Hoàn thành tập trung — gắn kết tăng thêm",
        "id": "Fokus selesai — ikatan diperkuat",
        "tr": "Odak tamamlandı — bağ güçlendi",
        "nl": "Focus voltooid — band versterkt",
        "pl": "Skupienie ukończone — więź wzmocniona",
        "uk": "Фокус завершено — зв'язок зміцнено",
        "ms": "Fokus selesai — ikatan diperkukuh",
    },
    "太好了！又一起专注啦": {
        "en": "Great! We focused together again!",
        "ja": "やった！また一緒に集中できた！",
        "ko": "좋아! 또 함께 집중했어!",
        "es": "¡Genial! ¡Enfocamos juntos otra vez!",
        "fr": "Super ! On a de nouveau focus ensemble !",
        "de": "Toll! Wir haben wieder zusammen fokussiert!",
        "pt-BR": "Ótimo! Focamos juntos de novo!",
        "ru": "Отлично! Мы снова сфокусировались вместе!",
        "ar": "رائع! ركزنا معاً مرة أخرى!",
        "hi": "बढ़िया! हमने फिर साथ में फ़ोकस किया!",
        "it": "Ottimo! Abbiamo di nuovo fatto focus insieme!",
        "th": "เยี่ยม! โฟกัสด้วยกันอีกแล้ว!",
        "vi": "Tuyệt! Chúng ta lại cùng tập trung!",
        "id": "Hebat! Kita fokus bersama lagi!",
        "tr": "Harika! Yine birlikte odaklandık!",
        "nl": "Geweldig! We hebben weer samen gefocust!",
        "pl": "Świetnie! Znowu skupiliśmy się razem!",
        "uk": "Чудово! Ми знову сфокусувалися разом!",
        "ms": "Hebat! Kita fokus bersama lagi!",
    },
    "初识": {
        "en": "New",
        "ja": "初めまして",
        "ko": "처음 만남",
        "es": "Nuevo",
        "fr": "Nouveau",
        "de": "Neu",
        "pt-BR": "Novo",
        "ru": "Знакомство",
        "ar": "جديد",
        "hi": "नया",
        "it": "Nuovo",
        "th": "เพิ่งรู้จัก",
        "vi": "Mới quen",
        "id": "Baru",
        "tr": "Yeni",
        "nl": "Nieuw",
        "pl": "Nowy",
        "uk": "Новий",
        "ms": "Baru",
    },
    "熟络": {
        "en": "Close",
        "ja": "なじみ",
        "ko": "친해짐",
        "es": "Cercano",
        "fr": "Proche",
        "de": "Vertraut",
        "pt-BR": "Próximo",
        "ru": "Близкий",
        "ar": "مقرّب",
        "hi": "घनिष्ठ",
        "it": "Vicino",
        "th": "สนิท",
        "vi": "Thân thiết",
        "id": "Akrab",
        "tr": "Yakın",
        "nl": "Vertrouwd",
        "pl": "Bliski",
        "uk": "Близький",
        "ms": "rapat",
    },
    "好久没一起专注了": {
        "en": "It's been a while since we focused together",
        "ja": "しばらく一緒に集中してないね",
        "ko": "우리 같이 집중한 지 꽤 됐어",
        "es": "Hace tiempo que no enfocamos juntos",
        "fr": "Ça fait un moment qu'on n'a pas focus ensemble",
        "de": "Wir haben schon lange nicht mehr zusammen fokussiert",
        "pt-BR": "Faz tempo que não focamos juntos",
        "ru": "Давно мы не фокусировались вместе",
        "ar": "مر وقت طويل منذ آخر تركيز معاً",
        "hi": "हमने काफ़ी समय से साथ में फ़ोकस नहीं किया",
        "it": "È passato un po' dall'ultimo focus insieme",
        "th": "ไม่ได้โฟกัสด้วยกันนานแล้ว",
        "vi": "Đã lâu chúng ta chưa cùng tập trung",
        "id": "Sudah lama kita tidak fokus bersama",
        "tr": "Birlikte odaklanalı uzun zaman oldu",
        "nl": "Het is lang geleden dat we samen focusten",
        "pl": "Dawno nie skupialiśmy się razem",
        "uk": "Давно ми не фокусувалися разом",
        "ms": "Sudah lama kita tidak fokus bersama",
    },
    "小伴": {
        "en": "Buddy",
        "ja": "ともだち",
        "ko": "친구",
        "es": "Compi",
        "fr": "Copain",
        "de": "Kumpel",
        "pt-BR": "Amiguinho",
        "ru": "Дружок",
        "ar": "رفيق",
        "hi": "दोस्त",
        "it": "Amico",
        "th": "เพื่อน",
        "vi": "Bạn nhỏ",
        "id": "Teman",
        "tr": "Dost",
        "nl": "Maatje",
        "pl": "Przyjaciel",
        "uk": "Друже",
        "ms": "Kawan",
    },
    "默契 +1": {
        "en": "Bond +1",
        "ja": "絆 +1",
        "ko": "유대 +1",
        "es": "Vínculo +1",
        "fr": "Lien +1",
        "de": "Bindung +1",
        "pt-BR": "Vínculo +1",
        "ru": "Связь +1",
        "ar": "رابطة +1",
        "hi": "बंधन +1",
        "it": "Legame +1",
        "th": "สายสัมพันธ์ +1",
        "vi": "Gắn kết +1",
        "id": "Ikatan +1",
        "tr": "Bağ +1",
        "nl": "Band +1",
        "pl": "Więź +1",
        "uk": "Зв'язок +1",
        "ms": "Ikatan +1",
    },
    "安静地陪在你旁边…": {
        "en": "Quietly keeping you company…",
        "ja": "そっとそばで寄り添っています…",
        "ko": "조용히 곁에서 함께하고 있어요…",
        "es": "Tranquilamente a tu lado…",
        "fr": "Tranquillement à tes côtés…",
        "de": "Ruhig an deiner Seite…",
        "pt-BR": "Quietamente ao seu lado…",
        "ru": "Тихо рядом с тобой…",
        "ar": "بجانبك بهدوء…",
        "hi": "चुपचाप साथ बैठा हूँ…",
        "it": "Tranquillamente al tuo fianco…",
        "th": "อยู่ข้างๆ อย่างเงียบๆ…",
        "vi": "Lặng lẽ ở bên cạnh bạn…",
        "id": "Diam-diam menemani di samping…",
        "tr": "Sessizce yanında…",
        "nl": "Rustig naast je…",
        "pl": "Cicho obok ciebie…",
        "uk": "Тихо поруч із тобою…",
        "ms": "Diam-diam menemani di sisi…",
    },
}


def make_string_entry(key: str, locale_map: dict[str, str]) -> dict:
    localizations = {
        "zh-Hans": {"stringUnit": {"state": "translated", "value": key}},
    }
    for locale, value in locale_map.items():
        localizations[locale] = {"stringUnit": {"state": "translated", "value": value}}
    trad = key.translate(
        str.maketrans(
            {
                "专": "專",
                "时": "時",
                "猫": "貓",
                "粮": "糧",
                "为": "為",
                "云": "雲",
                "关": "關",
                "显": "顯",
                "虽": "雖",
                "与": "與",
                "个": "個",
                "态": "態",
                "够": "夠",
                "吗": "嗎",
                "这": "這",
                "开": "開",
                "启": "啟",
                "将": "將",
                "会": "會",
                "总": "總",
                "记": "記",
                "积": "積",
                "续": "續",
                "过": "過",
                "静": "靜",
                "边": "邊",
                "载": "載",
                "请": "請",
                "设": "設",
                "统": "統",
                "毕": "畢",
                "后": "後",
                "还": "還",
                "种": "種",
                "对": "對",
                "没": "沒",
                "点": "點",
                "复": "復",
                "暂": "暫",
                "结": "結",
                "练": "練",
                "梦": "夢",
                "识": "識",
                "络": "絡",
                "伴": "伴",
                "默": "默",
                "契": "契",
                "从": "從",
                "图": "圖",
                "鉴": "鑑",
                "该": "該",
                "无": "無",
                "法": "法",
                "装": "裝",
                "试": "試",
                "筛": "篩",
                "选": "選",
                "条": "條",
                "件": "件",
                "搜": "搜",
                "索": "索",
                "伙": "夥",
                "拉": "拉",
                "取": "取",
                "最": "最",
                "新": "新",
                "包": "包",
                "已": "已",
                "下": "下",
            }
        )
    )
    localizations["zh-Hant"] = {"stringUnit": {"state": "translated", "value": trad}}
    return {"localizations": localizations}


def migrate_xcstrings() -> None:
    data = json.loads(LOCALIZABLE.read_text(encoding="utf-8"))
    strings = data["strings"]

    for old, new in KEY_RENAMES.items():
        if old in strings:
            entry = strings.pop(old)
            strings[new] = entry

    for key in list(REMOVE_KEYS):
        strings.pop(key, None)

    all_trans = {**RENAMED_TRANSLATIONS, **NEW_KEYS}
    for key, locale_map in all_trans.items():
        strings[key] = make_string_entry(key, locale_map)

    data["strings"] = strings
    LOCALIZABLE.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Updated {LOCALIZABLE}")


def migrate_locale_files() -> None:
    for path in LOCALES_DIR.glob("*.json"):
        locale = path.stem
        data = json.loads(path.read_text(encoding="utf-8"))

        for old, new in KEY_RENAMES.items():
            if old in data:
                data.pop(old)

        for key in REMOVE_KEYS:
            data.pop(key, None)

        for key, translations in RENAMED_TRANSLATIONS.items():
            if locale in translations:
                data[key] = translations[locale]

        for key, translations in NEW_KEYS.items():
            if locale in translations:
                data[key] = translations[locale]

        path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        print(f"Updated {path}")


def update_all_keys_in_generator() -> None:
    text = GEN_LOC.read_text(encoding="utf-8")
    for old, new in KEY_RENAMES.items():
        text = text.replace(f'"{old}"', f'"{new}"')
    for key in REMOVE_KEYS:
        text = text.replace(f'    "{key}",\n', "")
    insert_block = "\n".join(f'    "{k}",' for k in NEW_KEYS) + "\n"
    marker = '    "桌面浮窗",\n'
    if marker in text and "专注伙伴" not in text:
        text = text.replace(marker, marker + insert_block)
    GEN_LOC.write_text(text, encoding="utf-8")
    print(f"Updated {GEN_LOC}")


SITE_OVERRIDES: dict[str, dict[str, str]] = {
    "en": {
        "meta_description": "Attention Clock is a free Mac focus timer with 3000+ downloadable focus companions. Pomodoro sessions, heatmap stats, floating pixel characters. No account, data stays local.",
        "meta_keywords": "focus timer, focus companion, desktop companion, pomodoro, mac productivity, attention clock, open source, pixel character",
        "hero_lead": "A calm Mac focus timer with optional focus companions. Pick a pixel character from 3000+ options, float it on your desktop, and stay motivated while you work.",
        "f6_title": "3000+ focus companions",
        "f6_desc": "Browse the catalog, search characters, download favorites, and switch companions anytime.",
        "tab2_title": "Companions",
        "tab2_desc": "Browse, download, and manage pixel focus companions.",
        "nav_pets": "Companions",
        "meta_pets": "3000+ companions",
        "pets_title": "Focus companions by your side",
        "pets_sub": "Optional, lightweight, and surprisingly motivating — you don't have to focus alone.",
        "pet1_title": "Huge pixel catalog",
        "pet1_desc": "Browse 3000+ companions — characters, creatures, and more. Search and filter to find your favorite.",
        "pet2_title": "Reacts while you focus",
        "pet2_desc": "Your companion stays with you during sessions, changes expression, and celebrates when you finish.",
        "pet3_title": "Floats on your desktop",
        "pet3_desc": "Turn on the floating window to keep your companion visible across apps while you work.",
        "pet4_title": "Fully optional",
        "pet4_desc": "Enable or disable anytime. The timer works perfectly on its own — companions are pure bonus.",
        "faq5_q": "Do companions need the internet?",
        "faq5_a": "Only to browse and download new companions. Focus timing and stats work fully offline.",
        "footer_tagline": "Free Mac focus timer with optional companions. Sit down, focus, bring someone along.",
    },
    "zh-Hans": {
        "meta_description": "专注时钟是免费 Mac 专注计时器，内置 3000+ 可下载专注伙伴。番茄钟专注、热力图统计、像素角色桌面浮窗。无需注册，数据本地保存。",
        "meta_keywords": "专注计时, 专注伙伴, 桌面伙伴, 番茄钟, Mac 效率, 专注时钟, 开源, 像素角色",
        "hero_lead": "安静的 Mac 专注计时器，还可选专注伙伴陪你一起做事。从 3000+ 像素角色中挑选，放到桌面上，专注也更有动力。",
        "f6_title": "3000+ 专注伙伴",
        "f6_desc": "浏览角色图鉴、搜索下载、随时切换你的专注伙伴。",
        "tab2_title": "专注伙伴",
        "tab2_desc": "浏览、下载和管理像素专注伙伴。",
        "nav_pets": "专注伙伴",
        "meta_pets": "3000+ 专注伙伴",
        "pets_title": "专注伙伴，陪你一起专注",
        "pets_sub": "可选、轻量、却意外有动力——专注不必一个人硬撑。",
        "pet1_title": "海量像素图鉴",
        "pet1_desc": "3000+ 角色任你选——同人 IP、游戏角色、小动物等。支持搜索和筛选，找到最合眼缘的那位。",
        "pet2_title": "专注时有回应",
        "pet2_desc": "专注过程中伙伴会陪在身边，表情随状态变化，完成时还会庆祝。",
        "pet3_title": "桌面浮窗常驻",
        "pet3_desc": "开启浮窗后，伙伴在桌面可见，切应用也不耽误陪伴。",
        "pet4_title": "完全可选",
        "pet4_desc": "随时开关，不影响计时。就算不用伙伴，专注功能也完整好用。",
        "faq5_q": "专注伙伴需要联网吗？",
        "faq5_a": "浏览和下载新伙伴时需要网络。专注计时和统计可完全离线使用。",
        "footer_tagline": "带专注伙伴的免费 Mac 专注计时器。坐下来，专注，带个伙伴。",
    },
    "zh-Hant": {
        "meta_description": "專注時鐘是免費 Mac 專注計時器，內建 3000+ 可下載專注夥伴。番茄鐘專注、熱力圖統計、像素角色桌面浮窗。無需註冊，資料本地保存。",
        "meta_keywords": "專注計時, 專注夥伴, 桌面夥伴, 番茄鐘, Mac 效率, 專注時鐘, 開源, 像素角色",
        "hero_lead": "安靜的 Mac 專注計時器，還可選專注夥伴陪你一起做事。從 3000+ 像素角色中挑選，放到桌面上，專注也更有動力。",
        "f6_title": "3000+ 專注夥伴",
        "f6_desc": "瀏覽角色圖鑑、搜尋下載、隨時切換你的專注夥伴。",
        "tab2_title": "專注夥伴",
        "tab2_desc": "瀏覽、下載和管理像素專注夥伴。",
        "nav_pets": "專注夥伴",
        "meta_pets": "3000+ 專注夥伴",
        "pets_title": "專注夥伴，陪你一起專注",
        "pets_sub": "可選、輕量、卻意外有動力——專注不必一個人硬撐。",
        "pet1_title": "海量像素圖鑑",
        "pet1_desc": "3000+ 角色任你選——同人 IP、遊戲角色、小動物等。支援搜尋和篩選，找到最合眼緣的那位。",
        "pet2_title": "專注時有回應",
        "pet2_desc": "專注過程中夥伴會陪在身邊，表情隨狀態變化，完成時還會慶祝。",
        "pet3_title": "桌面浮窗常駐",
        "pet3_desc": "開啟浮窗後，夥伴在桌面可見，切應用也不耽誤陪伴。",
        "pet4_title": "完全可選",
        "pet4_desc": "隨時開關，不影響計時。就算不用夥伴，專注功能也完整好用。",
        "faq5_q": "專注夥伴需要連網嗎？",
        "faq5_a": "瀏覽和下載新夥伴時需要網路。專注計時和統計可完全離線使用。",
        "footer_tagline": "帶專注夥伴的免費 Mac 專注計時器。坐下來，專注，帶個夥伴。",
    },
    "ja": {
        "meta_description": "集中タイマーは無料の Mac 集中タイマー。3000体以上のダウンロード可能な集中パートナー、ポモドーロ、ヒートマップ、ピクセルキャラの浮窗付き。アカウント不要、データはローカル保存。",
        "meta_keywords": "集中タイマー, 集中パートナー, デスクトップ相棒, ポモドーロ, Mac 生産性, オープンソース, ピクセルキャラ",
        "hero_lead": "静かな Mac 集中タイマーに、任意の集中パートナーを。3000体以上のピクセルキャラから選んでデスクトップに置き、集中を後押し。",
        "f6_title": "3000+ 集中パートナー",
        "f6_desc": "図鑑を閲覧・検索・ダウンロードし、いつでも相棒を切り替え。",
        "tab2_title": "集中パートナー",
        "tab2_desc": "ピクセル相棒の閲覧・ダウンロード・管理。",
        "nav_pets": "集中パートナー",
        "meta_pets": "3000+ パートナー",
        "pets_title": "集中パートナーがそばにいる",
        "pets_sub": "任意・軽量・意外とやる気が出る——一人で頑張らなくていい。",
        "pet1_title": "巨大なピクセル図鑑",
        "pet1_desc": "3000体以上——キャラ、生物など。検索とフィルターでお気に入りを見つけよう。",
        "pet2_title": "集中中にリアクション",
        "pet2_desc": "セッション中そばにいて、表情が変わり、完了を祝ってくれる。",
        "pet3_title": "デスクトップに浮かぶ",
        "pet3_desc": "フローティングウィンドウでアプリを切り替えても見える。",
        "pet4_title": "完全オプション",
        "pet4_desc": "いつでもオン/オフ。タイマー単体でも十分使える。",
        "faq5_q": "パートナーにインターネットは必要？",
        "faq5_a": "閲覧・ダウンロード時のみ。集中タイマーと統計はオフラインで動作。",
        "footer_tagline": "集中パートナー付きの無料 Mac 集中タイマー。座って、集中して、誰かを連れて。",
    },
    "ko": {
        "meta_description": "집중 타이머는 3000개 이상의 다운로드 가능한 집중 파트너가 있는 무료 Mac 집중 타이머입니다. 포모도로, 히트맵, 픽셀 캐릭터 플로팅 창. 계정 불필요, 데이터 로컬 저장.",
        "meta_keywords": "집중 타이머, 집중 파트너, 데스크톱 동반자, 포모도로, Mac 생산성, 오픈소스, 픽셀 캐릭터",
        "hero_lead": "조용한 Mac 집중 타이머에 선택적인 집중 파트너를 더하세요. 3000개 이상의 픽셀 캐릭터 중 골라 바탕화면에 두고 집중하세요.",
        "f6_title": "3000+ 집중 파트너",
        "f6_desc": "도감을 탐색·검색·다운로드하고 언제든 동반자를 바꿀 수 있습니다.",
        "tab2_title": "집중 파트너",
        "tab2_desc": "픽셀 집중 파트너 탐색, 다운로드, 관리.",
        "nav_pets": "집중 파트너",
        "meta_pets": "3000+ 동반자",
        "pets_title": "집중 파트너가 곁에",
        "pets_sub": "선택 사항이지만 가볍고 의외로 동기부여가 됩니다 — 혼자 집중할 필요 없어요.",
        "pet1_title": "방대한 픽셀 도감",
        "pet1_desc": "3000개 이상 — 캐릭터, 생물 등. 검색과 필터로 마음에 드는 동반자를 찾으세요.",
        "pet2_title": "집중 중 반응",
        "pet2_desc": "세션 동안 곁에 있고, 표정이 바뀌며, 완료를 축하합니다.",
        "pet3_title": "데스크톱에 떠다님",
        "pet3_desc": "플로팅 창으로 앱을 바꿔도 동반자가 보입니다.",
        "pet4_title": "완전 선택",
        "pet4_desc": "언제든 켜고 끌 수 있습니다. 타이머만으로도 충분합니다.",
        "faq5_q": "동반자에 인터넷이 필요한가요?",
        "faq5_a": "탐색·다운로드할 때만 필요합니다. 집중 타이머와 통계는 오프라인으로 동작합니다.",
        "footer_tagline": "집중 파트너가 있는 무료 Mac 집중 타이머. 앉아서, 집중하고, 누군가를 데려오세요.",
    },
}


def migrate_site_i18n() -> None:
    data = json.loads(SITE_I18N.read_text(encoding="utf-8"))
    for locale, overrides in SITE_OVERRIDES.items():
        if locale in data:
            data[locale].update(overrides)
    # Fallback locales: apply English-style companion terminology via simple replacements on en base
    en = data["en"]
    companion_keys = [
        "meta_description", "meta_keywords", "hero_lead", "f6_title", "f6_desc",
        "tab2_title", "tab2_desc", "nav_pets", "meta_pets", "pets_title", "pets_sub",
        "pet1_title", "pet1_desc", "pet2_title", "pet2_desc", "pet3_title", "pet3_desc",
        "pet4_title", "pet4_desc", "faq5_q", "faq5_a", "footer_tagline",
    ]
    for locale in data:
        if locale in SITE_OVERRIDES:
            continue
        # keep existing locale text but swap pet terminology where obvious
        block = data[locale]
        for key in companion_keys:
            if key in en and key in block:
                val = block[key]
                val = re.sub(r"(?i)desktop pets?", "focus companions", val)
                val = re.sub(r"(?i)mascotas de escritorio", "compañeros de enfoque", val)
                val = re.sub(r"(?i)mascotte", "compagni", val)
                val = re.sub(r"(?i)haustier", "Begleiter", val)
                val = re.sub(r"桌面宠物", "专注伙伴", val)
                val = re.sub(r"宠物", "伙伴", val)
                block[key] = val
    SITE_I18N.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Updated {SITE_I18N}")


def main() -> None:
    migrate_xcstrings()
    migrate_locale_files()
    update_all_keys_in_generator()
    migrate_site_i18n()


if __name__ == "__main__":
    main()
