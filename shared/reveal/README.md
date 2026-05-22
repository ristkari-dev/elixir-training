# Vendored reveal.js

reveal.js 5.1.0 — https://github.com/hakimel/reveal.js/releases/tag/5.1.0

Copyright © 2011–2024 Hakim El Hattab and reveal.js contributors.
Licensed under MIT — see `LICENSE`.

This directory is **vendored** and should not be hand-edited.

## Provenance

- **Source:** https://github.com/hakimel/reveal.js/archive/refs/tags/5.1.0.tar.gz
- **Tarball SHA-256:** `ddc83539ec50583eac9a972e88f892971b37c44e70dd0c08be069e2688684b71`
- **Vendored on:** 2026-05-21
- **Vendored by:** Plan A, Task 3

## What is and is not vendored

Vendored (used at runtime by lesson slide decks):
- `dist/` — the reveal.js runtime: `reveal.js`, `reveal.css`, `reset.css`, themes, fonts.
- `plugin/` — the bundled plugins (highlight, markdown, notes, math, search, zoom).
- `LICENSE` — the upstream MIT license.

Excluded (build/dev artifacts not needed at runtime):
- `js/` — TypeScript/ES sources used to produce `dist/`.
- `gulpfile.js`, `package.json`, `package-lock.json`, `node_modules/` — build tooling.
- `test/`, `examples/`, the upstream `README.md` — non-runtime content.
- `.github/`, `.editorconfig` — repository metadata.

## Caveats

- `plugin/math/{katex.js,mathjax2.js,mathjax3.js}` are loader shims that fetch the
  actual math libraries from a CDN at runtime. Lessons that need offline math
  rendering will require an extra vendoring step (KaTeX/MathJax assets) not
  covered here.
- Themes other than `black.css` and `white.css` `@import` Google Fonts at runtime.
  Lessons authored against the default `black` theme are offline-safe.

## Updating

1. Re-download the tarball at the new version.
2. Verify its SHA-256 against the upstream release checksum (or re-record below).
3. Replace `dist/` and `plugin/` with the new ones.
4. Update the version line, source URL, SHA-256, and vendored-on date in this file.
