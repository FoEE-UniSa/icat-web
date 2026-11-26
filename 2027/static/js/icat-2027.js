// ICAT 2027 — small enhancements, no dependencies.
(function () {
  'use strict';

  // ---------- Theme ----------
  function currentTheme() {
    return document.documentElement.getAttribute('data-bs-theme') || 'light';
  }

  function syncThemeIcon() {
    var icon = document.querySelector('.icat-theme-toggle i');
    if (icon) {
      icon.className = currentTheme() === 'dark' ? 'bi bi-sun-fill' : 'bi bi-moon-stars-fill';
    }
  }

  function setTheme(theme) {
    document.documentElement.setAttribute('data-bs-theme', theme);
    localStorage.setItem('icat-theme', theme);
    syncThemeIcon();
  }

  syncThemeIcon();

  document.addEventListener('DOMContentLoaded', function () {
    var toggle = document.querySelector('.icat-theme-toggle');
    if (toggle) {
      toggle.addEventListener('click', function () {
        setTheme(currentTheme() === 'dark' ? 'light' : 'dark');
      });
    }
  });

  // ---------- Countdown ----------
  function pad(n) {
    return n < 10 ? '0' + n : '' + n;
  }

  function renderCountdown(el, start, end) {
    var now = Date.now();
    var name = el.getAttribute('data-event-name') || 'The conference';

    if (end && now > end.getTime()) {
      el.innerHTML = '<p class="icat-hero-status">' + name + ' has ended.</p>';
      return false;
    }

    if (now >= start.getTime()) {
      el.innerHTML = '<p class="icat-hero-status">' + name + ' is under way.</p>';
      return false;
    }

    var diff = start.getTime() - now;

    var days = Math.floor(diff / 86400000);
    var hours = Math.floor((diff % 86400000) / 3600000);
    var minutes = Math.floor((diff % 3600000) / 60000);
    var seconds = Math.floor((diff % 60000) / 1000);

    el.innerHTML =
      '<div class="icat-countdown-unit"><div class="number">' + pad(days) + '</div><div class="label">Days</div></div>' +
      '<div class="icat-countdown-unit"><div class="number">' + pad(hours) + '</div><div class="label">Hours</div></div>' +
      '<div class="icat-countdown-unit"><div class="number">' + pad(minutes) + '</div><div class="label">Minutes</div></div>' +
      '<div class="icat-countdown-unit"><div class="number">' + pad(seconds) + '</div><div class="label">Seconds</div></div>';

    return true;
  }

  function startCountdowns() {
    document.querySelectorAll('[data-countdown]').forEach(function (el) {
      var start = new Date(el.getAttribute('data-countdown'));
      var endValue = el.getAttribute('data-countdown-end');
      var end = endValue ? new Date(endValue) : null;
      if (isNaN(start.getTime())) return;

      if (renderCountdown(el, start, end)) {
        var timer = setInterval(function () {
          if (!renderCountdown(el, start, end)) clearInterval(timer);
        }, 1000);
      }
    });
  }

  // ---------- Navbar shadow ----------
  function startNavbarShadow() {
    var nav = document.querySelector('.icat-navbar');
    if (!nav) return;

    function onScroll() {
      nav.classList.toggle('scrolled', window.scrollY > 20);
    }

    window.addEventListener('scroll', onScroll, { passive: true });
    onScroll();
  }

  // ---------- Reveal on scroll ----------
  function startReveal() {
    var targets = document.querySelectorAll('.reveal');
    if (!targets.length) return;

    if (!('IntersectionObserver' in window)) {
      targets.forEach(function (el) { el.classList.add('visible'); });
      return;
    }

    var observer = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) {
          entry.target.classList.add('visible');
          observer.unobserve(entry.target);
        }
      });
    }, { threshold: 0.08, rootMargin: '0px 0px -40px 0px' });

    targets.forEach(function (el) { observer.observe(el); });
  }

  document.addEventListener('DOMContentLoaded', function () {
    startCountdowns();
    startNavbarShadow();
    startReveal();
  });
})();
