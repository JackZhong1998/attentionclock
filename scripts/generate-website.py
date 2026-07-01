#!/usr/bin/env python3
"""Generate static multilingual SEO-friendly website pages."""

from __future__ import annotations

import html
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
WEBSITE = ROOT / "website"
DATA = WEBSITE / "data"
METADATA = json.loads((ROOT / "scripts" / "languages-metadata.json").read_text(encoding="utf-8"))

VERSION = METADATA["version"]
REPO = METADATA["repo"]
SITE_URL = "https://jackzhong1998.github.io/attentionclock"


def page_url(lang: str = "") -> str:
    if lang:
        return f"{SITE_URL}/{lang}/"
    return f"{SITE_URL}/"

LOCALES = list(METADATA["locales"].keys())
RTL_LOCALES = {"ar"}


def t(lang: str, key: str, default: str = "") -> str:
    return I18N.get(lang, {}).get(key, I18N.get("en", {}).get(key, default))


def feature_items(lang: str) -> list[dict[str, str]]:
    return [
        {
            "icon": "⚡",
            "title": t(lang, "f1_title"),
            "desc": t(lang, "f1_desc"),
        },
        {
            "icon": "🎯",
            "title": t(lang, "f2_title"),
            "desc": t(lang, "f2_desc"),
        },
        {
            "icon": "⏱️",
            "title": t(lang, "f3_title"),
            "desc": t(lang, "f3_desc"),
        },
        {
            "icon": "🌳",
            "title": t(lang, "f4_title"),
            "desc": t(lang, "f4_desc"),
        },
        {
            "icon": "📊",
            "title": t(lang, "f5_title"),
            "desc": t(lang, "f5_desc"),
        },
        {
            "icon": "🐱",
            "title": t(lang, "f6_title"),
            "desc": t(lang, "f6_desc"),
        },
        {
            "icon": "🔓",
            "title": t(lang, "f7_title"),
            "desc": t(lang, "f7_desc"),
        },
    ]


def step_items(lang: str) -> list[dict[str, str]]:
    return [
        {"title": t(lang, "s1_title"), "desc": t(lang, "s1_desc")},
        {"title": t(lang, "s2_title"), "desc": t(lang, "s2_desc")},
        {"title": t(lang, "s3_title"), "desc": t(lang, "s3_desc")},
    ]


def tab_items(lang: str) -> list[dict[str, str]]:
    return [
        {"title": t(lang, "tab1_title"), "desc": t(lang, "tab1_desc")},
        {"title": t(lang, "tab2_title"), "desc": t(lang, "tab2_desc")},
        {"title": t(lang, "tab3_title"), "desc": t(lang, "tab3_desc")},
        {"title": t(lang, "tab4_title"), "desc": t(lang, "tab4_desc")},
    ]


def pet_items(lang: str) -> list[dict[str, str]]:
    return [
        {"icon": "📚", "title": t(lang, "pet1_title"), "desc": t(lang, "pet1_desc")},
        {"icon": "💬", "title": t(lang, "pet2_title"), "desc": t(lang, "pet2_desc")},
        {"icon": "🪟", "title": t(lang, "pet3_title"), "desc": t(lang, "pet3_desc")},
        {"icon": "✨", "title": t(lang, "pet4_title"), "desc": t(lang, "pet4_desc")},
    ]


def faq_items(lang: str) -> list[dict[str, str]]:
    items = [
        {"q": t(lang, "faq1_q"), "a": t(lang, "faq1_a")},
        {"q": t(lang, "faq2_q"), "a": t(lang, "faq2_a")},
        {"q": t(lang, "faq3_q"), "a": t(lang, "faq3_a")},
        {"q": t(lang, "faq4_q"), "a": t(lang, "faq4_a")},
    ]
    if t(lang, "faq5_q"):
        items.append({"q": t(lang, "faq5_q"), "a": t(lang, "faq5_a")})
    return items


def install_steps(lang: str) -> list[str]:
    return [t(lang, f"install{i}") for i in range(1, 5)]


def lang_options(current: str) -> str:
    opts = []
    for code in LOCALES:
        label = METADATA["locales"][code]["label"]
        if code == current:
            href = "."
        else:
            href = f"../{code}/"
        selected = " selected" if code == current else ""
        opts.append(f'<option value="{href}"{selected}>{html.escape(label)}</option>')
    return "\n".join(opts)


def hreflang_tags() -> str:
    tags = []
    for code in LOCALES:
        path = page_url(code)
        tags.append(f'<link rel="alternate" hreflang="{code}" href="{path}">')
    tags.append(f'<link rel="alternate" hreflang="x-default" href="{page_url("en")}">')
    return "\n  ".join(tags)


def json_ld(lang: str) -> str:
    title = METADATA["locales"][lang]["title"]
    data = {
        "@context": "https://schema.org",
        "@type": "SoftwareApplication",
        "name": title,
        "applicationCategory": "ProductivityApplication",
        "operatingSystem": "macOS 14.0+",
        "offers": {"@type": "Offer", "price": "0", "priceCurrency": "USD"},
        "downloadUrl": f"{REPO}/releases/latest",
        "softwareVersion": VERSION,
        "description": t(lang, "meta_description"),
        "url": page_url(lang),
        "author": {"@type": "Organization", "name": "Attention Clock"},
        "isAccessibleForFree": True,
        "license": "https://opensource.org/licenses/MIT",
    }
    return json.dumps(data, ensure_ascii=False)


def render_page(lang: str) -> str:
    meta = METADATA["locales"][lang]
    title = meta["title"]
    direction = "rtl" if lang in RTL_LOCALES else "ltr"
    canonical = page_url(lang)
    og_image = f"{SITE_URL}/assets/og-image.png"
    asset_prefix = "../assets"
    page_title = t(lang, "meta_title").format(app=title)
    description = t(lang, "meta_description")

    features_html = "\n".join(
        f"""        <article class="feature-card">
          <div class="feature-icon">{html.escape(f["icon"])}</div>
          <h3>{html.escape(f["title"])}</h3>
          <p>{html.escape(f["desc"])}</p>
        </article>"""
        for f in feature_items(lang)
    )

    steps_html = "\n".join(
        f"""        <article class="step-card">
          <h3>{html.escape(s["title"])}</h3>
          <p>{html.escape(s["desc"])}</p>
        </article>"""
        for s in step_items(lang)
    )

    tabs_html = "\n".join(
        f"""        <article class="tab-card">
          <h3>{html.escape(tab["title"])}</h3>
          <p>{html.escape(tab["desc"])}</p>
        </article>"""
        for tab in tab_items(lang)
    )

    pets_html = "\n".join(
        f"""        <article class="pet-card">
          <div class="pet-icon">{html.escape(p["icon"])}</div>
          <h3>{html.escape(p["title"])}</h3>
          <p>{html.escape(p["desc"])}</p>
        </article>"""
        for p in pet_items(lang)
    )

    faq_html = "\n".join(
        f"""        <div class="faq-item">
          <button class="faq-question" type="button" aria-expanded="false">{html.escape(item["q"])}</button>
          <div class="faq-answer"><p>{html.escape(item["a"])}</p></div>
        </div>"""
        for item in faq_items(lang)
    )

    install_html = "\n".join(
        f"          <li>{html.escape(step)}</li>" for step in install_steps(lang)
    )

    return f"""<!DOCTYPE html>
<html lang="{lang}" dir="{direction}">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>{html.escape(page_title)}</title>
  <meta name="description" content="{html.escape(description)}">
  <meta name="keywords" content="{html.escape(t(lang, "meta_keywords"))}">
  <meta name="author" content="Attention Clock">
  <meta name="robots" content="index, follow">
  <link rel="canonical" href="{canonical}">
  {hreflang_tags()}
  <meta property="og:type" content="website">
  <meta property="og:title" content="{html.escape(page_title)}">
  <meta property="og:description" content="{html.escape(description)}">
  <meta property="og:url" content="{canonical}">
  <meta property="og:image" content="{og_image}">
  <meta property="og:locale" content="{lang.replace("-", "_")}">
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="{html.escape(page_title)}">
  <meta name="twitter:description" content="{html.escape(description)}">
  <meta name="twitter:image" content="{og_image}">
  <link rel="icon" href="{asset_prefix}/icon.png" type="image/png">
  <link rel="apple-touch-icon" href="{asset_prefix}/icon.png">
  <link rel="stylesheet" href="{asset_prefix}/style.css">
  <script type="application/ld+json">{json_ld(lang)}</script>
</head>
<body>
  <header class="site-header">
    <div class="container">
      <a class="brand" href="#top">
        <img src="{asset_prefix}/icon.png" width="32" height="32" alt="{html.escape(title)}">
        <span>{html.escape(title)}</span>
      </a>
      <button class="menu-toggle" type="button" aria-label="Menu" aria-expanded="false">☰</button>
      <nav class="nav-main" aria-label="Main">
        <a href="#features">{html.escape(t(lang, "nav_features"))}</a>
        <a href="#pets">{html.escape(t(lang, "nav_pets"))}</a>
        <a href="#how">{html.escape(t(lang, "nav_how"))}</a>
        <a href="#download">{html.escape(t(lang, "nav_download"))}</a>
        <a href="#faq">{html.escape(t(lang, "nav_faq"))}</a>
      </nav>
      <div class="header-actions">
        <select id="lang-select" class="lang-select" aria-label="{html.escape(t(lang, "lang_label"))}">
{lang_options(lang)}
        </select>
        <a class="btn btn-secondary" href="{REPO}" rel="noopener">GitHub</a>
      </div>
    </div>
  </header>

  <main id="top">
    <section class="hero">
      <div class="container">
        <span class="hero-badge">{html.escape(t(lang, "hero_badge").format(version=VERSION))}</span>
        <h1>{html.escape(t(lang, "hero_title").format(app=title))}</h1>
        <p class="hero-lead">{html.escape(t(lang, "hero_lead"))}</p>
        <div class="hero-cta">
          <div class="hero-download-panel">
            <div class="chip-toggle hero-chip-toggle" role="group" aria-label="Chip">
              <button class="chip-btn active" type="button" data-chip="arm64">{html.escape(t(lang, "chip_arm"))}</button>
              <button class="chip-btn" type="button" data-chip="x86_64">{html.escape(t(lang, "chip_intel"))}</button>
            </div>
            <a id="hero-download" class="btn btn-primary btn-lg" href="#" rel="noopener">{html.escape(t(lang, "download_btn"))}</a>
          </div>
          <a class="btn btn-secondary btn-lg" href="{REPO}" rel="noopener">{html.escape(t(lang, "hero_github"))}</a>
        </div>
        <div class="hero-meta">
          <span>✓ {html.escape(t(lang, "meta_free"))}</span>
          <span>✓ {html.escape(t(lang, "meta_local"))}</span>
          <span>🐾 {html.escape(t(lang, "meta_pets"))}</span>
          <span>✓ macOS 14+</span>
        </div>
      </div>
    </section>

    <section class="preview">
      <div class="container">
        <div class="mockup-wrap" role="img" aria-label="{html.escape(t(lang, "preview_aria"))}">
          <div class="mockup-bar"><span></span><span></span><span></span></div>
          <div class="mockup-body">
            <div class="mockup-sidebar">
              <div class="mockup-tab active">{html.escape(t(lang, "tab1_title"))}</div>
              <div class="mockup-tab">{html.escape(t(lang, "tab2_title"))}</div>
              <div class="mockup-tab">{html.escape(t(lang, "tab3_title"))}</div>
              <div class="mockup-tab">{html.escape(t(lang, "tab4_title"))}</div>
            </div>
            <div class="mockup-main">
              <div class="timer-ring">
                <svg viewBox="0 0 140 140" aria-hidden="true">
                  <circle class="track" cx="70" cy="70" r="65"></circle>
                  <circle class="progress" cx="70" cy="70" r="65"></circle>
                </svg>
                <div class="timer-label">25:00<small>{html.escape(t(lang, "preview_focus"))}</small></div>
              </div>
              <div class="mockup-actions">
                <span class="mockup-btn">{html.escape(t(lang, "preview_start"))}</span>
                <span class="mockup-btn ghost">−</span>
                <span class="mockup-btn ghost">+</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <section id="features" class="section section-alt">
      <div class="container">
        <header class="section-header">
          <h2>{html.escape(t(lang, "features_title"))}</h2>
          <p>{html.escape(t(lang, "features_sub"))}</p>
        </header>
        <div class="features-grid">
{features_html}
        </div>
      </div>
    </section>

    <section id="pets" class="section">
      <div class="container">
        <header class="section-header">
          <h2>{html.escape(t(lang, "pets_title"))}</h2>
          <p>{html.escape(t(lang, "pets_sub"))}</p>
        </header>
        <div class="pets-layout">
          <div class="pets-visual" aria-hidden="true">
            <div class="float-window">
              <div class="float-bar"><span></span><span></span><span></span></div>
              <div class="float-pet">🐱</div>
              <div class="float-caption">{html.escape(t(lang, "tab2_title"))}</div>
            </div>
            <div class="desk-pet-grid">
              <span>🐈</span><span>🦊</span><span>🐰</span><span>🐻</span>
              <span>🐼</span><span>🐶</span><span>🐹</span><span>🦁</span>
            </div>
          </div>
          <div class="pets-grid">
{pets_html}
          </div>
        </div>
      </div>
    </section>

    <section id="how" class="section section-alt">
      <div class="container">
        <header class="section-header">
          <h2>{html.escape(t(lang, "how_title"))}</h2>
          <p>{html.escape(t(lang, "how_sub"))}</p>
        </header>
        <div class="steps">
{steps_html}
        </div>
      </div>
    </section>

    <section class="section">
      <div class="container">
        <header class="section-header">
          <h2>{html.escape(t(lang, "tabs_section_title"))}</h2>
        </header>
        <div class="tabs-grid">
{tabs_html}
        </div>
      </div>
    </section>

    <section id="download" class="section section-alt">
      <div class="container">
        <header class="section-header">
          <h2>{html.escape(t(lang, "download_title"))}</h2>
          <p>{html.escape(t(lang, "download_sub"))}</p>
        </header>
        <div class="download-panel">
          <div class="chip-toggle" role="group" aria-label="Chip">
            <button class="chip-btn active" type="button" data-chip="arm64">{html.escape(t(lang, "chip_arm"))}</button>
            <button class="chip-btn" type="button" data-chip="x86_64">{html.escape(t(lang, "chip_intel"))}</button>
          </div>
          <div class="download-actions">
            <a id="download-primary" class="btn btn-primary btn-lg" href="#" rel="noopener">{html.escape(t(lang, "download_btn"))}</a>
            <a class="btn btn-secondary" href="{REPO}/releases/latest" rel="noopener">{html.escape(t(lang, "download_all"))}</a>
          </div>
          <div class="download-note">
            <strong>{html.escape(t(lang, "install_title"))}</strong>
            <ol>
{install_html}
            </ol>
          </div>
        </div>
      </div>
    </section>

    <section id="faq" class="section section-alt">
      <div class="container">
        <header class="section-header">
          <h2>{html.escape(t(lang, "faq_title"))}</h2>
        </header>
        <div class="faq-list">
{faq_html}
        </div>
      </div>
    </section>
  </main>

  <footer class="site-footer">
    <div class="container">
      <div class="footer-grid">
        <div class="footer-brand">
          <a class="brand" href="#top">
            <img src="{asset_prefix}/icon.png" width="32" height="32" alt="">
            <span>{html.escape(title)}</span>
          </a>
          <p>{html.escape(t(lang, "footer_tagline"))}</p>
        </div>
        <div class="footer-links">
          <a href="{REPO}" rel="noopener">GitHub</a>
          <a href="{REPO}/releases/latest" rel="noopener">{html.escape(t(lang, "nav_download"))}</a>
          <a href="#features">{html.escape(t(lang, "nav_features"))}</a>
          <a href="#pets">{html.escape(t(lang, "nav_pets"))}</a>
          <a href="#faq">{html.escape(t(lang, "nav_faq"))}</a>
        </div>
      </div>
      <div class="footer-bottom">
        {html.escape(t(lang, "footer_copy").format(year="2026", repo=REPO))}
      </div>
    </div>
  </footer>

  <script src="{asset_prefix}/app.js" data-lang="{lang}" data-version="{VERSION}"></script>
</body>
</html>
"""


def render_root_redirect() -> str:
    langs = json.dumps(LOCALES)
    return f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Attention Clock</title>
  <meta http-equiv="refresh" content="0; url=en/">
  <link rel="canonical" href="{page_url("en")}">
  <script>
    (function() {{
      var locales = {langs};
      var nav = (navigator.language || "en").replace("_", "-");
      var match = locales.find(function(l) {{ return nav === l || nav.startsWith(l + "-"); }});
      if (!match && nav.startsWith("zh")) match = nav.includes("TW") || nav.includes("HK") ? "zh-Hant" : "zh-Hans";
      window.location.replace((match || "en") + "/");
    }})();
  </script>
</head>
<body>
  <p><a href="en/">Attention Clock</a></p>
</body>
</html>
"""


def render_sitemap() -> str:
    urls = []
    for code in LOCALES:
        urls.append(
            f"""  <url>
    <loc>{page_url(code)}</loc>
    <changefreq>monthly</changefreq>
    <priority>{"1.0" if code == "en" else "0.9"}</priority>
  </url>"""
        )
    urls.append(
        f"""  <url>
    <loc>{page_url()}</loc>
    <changefreq>monthly</changefreq>
    <priority>0.8</priority>
  </url>"""
    )
    return (
        '<?xml version="1.0" encoding="UTF-8"?>\n'
        '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n'
        + "\n".join(urls)
        + "\n</urlset>\n"
    )


def render_robots() -> str:
    return f"""User-agent: *
Allow: /

Sitemap: {page_url()}sitemap.xml
"""


# Load translations from data file
I18N: dict[str, dict[str, str]] = json.loads((DATA / "site-i18n.json").read_text(encoding="utf-8"))


def main() -> None:
    for lang in LOCALES:
        out_dir = WEBSITE / lang
        out_dir.mkdir(parents=True, exist_ok=True)
        (out_dir / "index.html").write_text(render_page(lang), encoding="utf-8")
        print(f"Generated {out_dir / 'index.html'}")

    (WEBSITE / "index.html").write_text(render_root_redirect(), encoding="utf-8")
    (WEBSITE / "sitemap.xml").write_text(render_sitemap(), encoding="utf-8")
    (WEBSITE / "robots.txt").write_text(render_robots(), encoding="utf-8")
    (WEBSITE / ".nojekyll").write_text("", encoding="utf-8")
    print("Generated website/index.html, sitemap.xml, robots.txt, .nojekyll")


if __name__ == "__main__":
    main()
