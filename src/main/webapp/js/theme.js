/* ================================================================
   THEME TOGGLE — Dark (default) / Light
   Persists choice in localStorage, applies before paint via inline
   script in <head> to avoid flash-of-wrong-theme.
================================================================ */
(function () {
    function applyTheme(theme) {
        if (theme === 'light') {
            document.documentElement.setAttribute('data-theme', 'light');
        } else {
            document.documentElement.removeAttribute('data-theme');
        }
    }

    function getStoredTheme() {
        try { return localStorage.getItem('te-theme'); } catch (e) { return null; }
    }

    function setStoredTheme(theme) {
        try { localStorage.setItem('te-theme', theme); } catch (e) {}
    }

    // Wire up toggle button once DOM is ready
    document.addEventListener('DOMContentLoaded', function () {
        const toggle = document.getElementById('themeToggle');
        if (!toggle) return;

        const current = getStoredTheme() || 'dark';
        applyTheme(current);
        updateIcon(current);

        toggle.addEventListener('click', function () {
            const isLight = document.documentElement.getAttribute('data-theme') === 'light';
            const next = isLight ? 'dark' : 'light';
            applyTheme(next);
            setStoredTheme(next);
            updateIcon(next);
        });

        function updateIcon(theme) {
            const icon = toggle.querySelector('.theme-icon');
            if (icon) {
                icon.className = 'theme-icon fas ' + (theme === 'light' ? 'fa-sun' : 'fa-moon');
            }
        }
    });

    // Mobile hamburger menu
    document.addEventListener('DOMContentLoaded', function () {
        const burger = document.getElementById('hamburger');
        const navEl  = document.getElementById('mainNav');
        if (burger && navEl) {
            burger.addEventListener('click', function () {
                navEl.classList.toggle('open');
            });
        }
    });
})();
