# Site-wide look (roll out the fact sheet design)

**Status:** APPROVED 2026-11-06 (Peter: page styling first, then figures). Parent: `2026-11-06_fact-sheet-design.md`.

## A. Page styling (website repo)

- New `aa-theme.css`: Public Sans, the design tokens (renamed `--aa-*`) on `:root`, headings, links, buttons,
  plain tables. Loaded by every page: `_quarto.yml` (`css: [aa-theme.css, styles.css]`) and `1_visuals.qmd`
  (`css: [aa-theme.css, dashboard.css]`), since dashboard pages do not inherit `format: html` options.
- `dashboard.css`: card, header, tabset and download-button rules move from `#fact-sheet` to every dashboard tab;
  fact-sheet-only pieces (tiles, tables, header) stay scoped.
- Navbar and tab bar keep the slate; links in ink with an underline (maroon stays reserved for the latest year).
- Check: screenshots of every tab and page at 1400 and 400 px; no horizontal overflow.

## B. Figures (graphics repo, after A is pushed)

- Recolour the ggplot figures: slate/grey bars, latest year maroon where a year axis exists, Public Sans, plain
  captions. One idea per figure, bars from zero, direct labels (Carpe-simple rule). Interactive ggiraph widgets
  follow the same palette. Only figures whose pixels change are committed.
