# Light/dark toggle for the site and every figure

**Status:** COMPLETED 2026-11-09 (Peter approved the three-figure preview; built the same day, see `../2026-11-09_light-dark.md`). Direction from `docs/logs/2026-09-10_dark-plot-side-quest-and-theming-note.md`
(two variants of every figure; Pete prefers dark with saturated marks; the toggle swaps figures too).

## Verified today

- Quarto 1.7.18 dashboards accept `theme: {light: ..., dark: ...}` and render the navbar toggle (test render in scratch).
- `::: {.light-content}` / `::: {.dark-content}` hide the other theme's copy (`body.quarto-light .dark-content {display:none}`).
- `aa-theme.css` already carries the dark tokens under `.quarto-dark`.

## A. Site chrome (website repo)

- `_quarto.yml` and `1_visuals.qmd`: `theme: {light: [flatly, aa-light.scss], dark: [darkly, aa-dark.scss]}`. Remove the
  page-level `theme: "flatly"` from index, victims, contact, codebook (they override the site setting).
- `aa-dark.scss`: Bootstrap variables from the dark tokens (body #141a21, text #e4e8ec, cards #1b232c, borders #2e3843,
  navbar stays slate) so cards, DT, tabsets and the footer fit; our own components already switch via `--aa-*`.
- Default: light. The toggle is Quarto's own, in the navbar, remembered per browser.

## B. Figures (graphics repo)

- `0_packages.R`: `aa_mode <- Sys.getenv("AA_MODE", "light")`; one token list per mode (paper, ink, muted, rule, light,
  maroon, land, tab colours). Dark marks are the stronger validated set (`aa_cat`) and a brighter maroon; `rank_shades()`
  fades toward dark instead of light; `theme_aa()`, maps and `save_girafe_widget()` read the tokens (widget page
  background + tooltip). Light output unchanged at `output/`; dark twins at `output/dark/` with the same names.
- Run each plot script twice (`AA_MODE=dark Rscript ...`): 14 PNGs, 3 ggiraph widgets, state map PNG+HTML, rolling GIF,
  latest-year map SVG (Home hero and Fact Sheet tab). The fact sheet PDF and its thumbnail stay light.
- Preview first: dark versions of three figures (by year, relationship, wounded/killed) for Peter before the full run.

## C. Swapping on the site

- `update_aa_graphics()` copies the dark twins to `www/dark/`.
- Every figure, iframe and map on `1_visuals.qmd`, the Home hero map and the Fact Sheet map get a light/dark pair in
  `.light-content` / `.dark-content` wrappers. Download buttons sit inside the same wrappers, so a download is the
  variant on screen.

## D. Check

- Headless screenshots of every tab and page in both modes at 1400 and 800 px; DT, widgets (own background inside the
  iframe), maps, hero band, Remembrance tags, codebook tables.
- CI unaffected (figures are committed; the runner renders qmd only).

## Decisions for Peter

1. Default light, Quarto's navbar toggle: yes?
2. Dark marks: saturated set + brighter maroon, confirmed from the three-figure preview.
3. Downloads follow the toggle (no extra buttons).
4. Fact sheet PDF stays light-only.
