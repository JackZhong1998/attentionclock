(function () {
  "use strict";

  var script = document.currentScript;
  var lang = (script && script.dataset.lang) || "en";
  var version = (script && script.dataset.version) || "1.0.0";
  var repo = "https://github.com/JackZhong1998/attentionclock";
  var releasesLatest = repo + "/releases/latest";
  var releasesBase = repo + "/releases/download/v" + version;

  function dmgUrl(arch) {
    return releasesBase + "/AttentionClock-" + version + "-" + lang + "-" + arch + ".dmg";
  }

  function detectChip() {
    var ua = navigator.userAgent || "";
    if (/Intel Mac OS X/i.test(ua)) return "x86_64";
    if (/Mac OS X/i.test(ua)) return "arm64";
    return "arm64";
  }

  var activeChip = detectChip();

  function setChip(chip) {
    activeChip = chip;
    document.querySelectorAll(".chip-btn").forEach(function (btn) {
      btn.classList.toggle("active", btn.dataset.chip === chip);
    });
    var primary = document.getElementById("download-primary");
    if (primary) primary.href = dmgUrl(chip);
  }

  document.querySelectorAll(".chip-btn").forEach(function (btn) {
    btn.addEventListener("click", function () {
      setChip(btn.dataset.chip);
    });
  });

  setChip(activeChip);

  var heroDownload = document.getElementById("hero-download");
  if (heroDownload) heroDownload.href = dmgUrl(activeChip);

  var langSelect = document.getElementById("lang-select");
  if (langSelect) {
    langSelect.addEventListener("change", function () {
      var target = langSelect.value;
      if (target && target !== lang) {
        window.location.href = target;
      }
    });
  }

  var menuToggle = document.querySelector(".menu-toggle");
  var navMain = document.querySelector(".nav-main");
  if (menuToggle && navMain) {
    menuToggle.addEventListener("click", function () {
      navMain.classList.toggle("open");
      menuToggle.setAttribute(
        "aria-expanded",
        navMain.classList.contains("open") ? "true" : "false"
      );
    });
  }

  document.querySelectorAll(".faq-question").forEach(function (btn) {
    btn.addEventListener("click", function () {
      var item = btn.closest(".faq-item");
      var open = item.classList.contains("open");
      document.querySelectorAll(".faq-item").forEach(function (el) {
        el.classList.remove("open");
        el.querySelector(".faq-question").setAttribute("aria-expanded", "false");
      });
      if (!open) {
        item.classList.add("open");
        btn.setAttribute("aria-expanded", "true");
      }
    });
  });
})();
