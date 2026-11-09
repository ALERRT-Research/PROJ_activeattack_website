# 2026-11-09: Light/dark toggle for the site and every figure

Plan: `plans/2026-11-09_light-dark.md` (approved after a three-figure dark preview: by year, relationship,
wounded/killed; Peter: "those look good").

## Graphics repo

- `0_packages.R`: `aa_mode <- Sys.getenv("AA_MODE", "light")`; one token list per mode (paper, ink, muted, light,
  rule, maroon, tab colours), `aa_cat`, `weapon_pal_cat`, `aa_land`, the tooltip CSS and `rank_shades()` (fades toward
  the page: lighter on light, darker on dark) all read the mode. `theme_aa()`, `aa_theme_bits` (cowplot themes) and
  `create_interactive_map()` take their backgrounds from `aa_paper`. `make_bi_pal()` adds the two ramps to a dark land
  instead of multiplying (multiplying over a dark base blew out). Dark marks: ochre #dba54c, blue #5f9ce3, green
  #4fb48f, violet #a892e6; latest year #e3566f.
- `out()` routes every save to `../output/` (light) or `../output/dark/` (dark, same names). All `"white"` literals
  in the three figure scripts became `aa_paper`; the latest-year map's hard-coded land and maroon became tokens.
- `generate_wound_killed_plot()` lost its `bw` switch (the 2026-09-10 one-off); `AA_MODE=dark` supersedes it.
  `output/bivar_wound_kill_bw.png` is still tracked but no longer produced; delete when Peter says so.
- Rendered: `AA_MODE=dark Rscript plots_cartesian.R`, `plots_geospatial.R`, `plots_latest_year_map.R` (20 files in
  `output/dark/`). Light outputs untouched (light `aa_paper` is "white", so a light re-render is byte-stable).

## Website

- `_quarto.yml` and `1_visuals.qmd`: `theme: {light: flatly, dark: [darkly, aa-dark.scss]}`; the page-level
  `theme: "flatly"` lines on index, victims, contact and codebook removed (they overrode the site pair). Quarto's
  navbar toggle appears on every page; the dashboard also shows Quarto's own toggle at the right of the tab bar.
- `aa-dark.scss`: Bootstrap variables from the dark tokens. `aa-theme.css`: `body.quarto-dark` token block, tab
  colours as `--aa-tab-*` variables per mode (dashboard.css and the Home cards reference them), `.rem-tag` and
  `.aa-subhead` text in `--aa-paper` so it stays readable when ink is light.
- Figure pairs: every `![](www/x)` on the dashboard is wrapped in `::: {.light-content}` / `::: {.dark-content}`
  with `www/dark/x`; iframes and the Home/Fact Sheet maps are paired the same way (`aa_img_pair()` in
  `R/page_helpers.R`). **The hide rules need `!important`** because the pair members carry their own display rules
  (iframes block, download links inline-flex), which otherwise win on specificity or order.
- Figure downloads are now plain `<a class="aa-dl" download>` links, one per theme, instead of downloadthis buttons.
  downloadthis embeds every file as base64; the dashboard page shrank from 13.8 MB to 1.2 MB. The data, fact sheet
  and codebook downloads keep downloadthis.
- `update_aa_graphics()` copies the dark twins to `www/dark/` from a single file list (warns if a twin is missing).

## Checking dark mode in headless Chrome

Quarto ignores localStorage for `file://` pages (it keeps the sentinel in a JS variable), so a scratch copy of
`_site` with `window.quartoToggleColorScheme()` called on load gives dark screenshots. Checked: Home, every dashboard
tab, Remembrance, Codebook, Contact, the dark widgets and the dark GIF, at 1400 px; light unchanged.

## Open

- The dark state map (additive bivariate blend) is readable but the top corner runs pale; Peter to judge.
- Deleting `output/bivar_wound_kill_bw.png` (graphics) needs approval.

## Toggle fix (same evening)

Peter: the toggles did nothing on the local pages, and the dashboard showed two. Playwright click test (`scratch
toggle_test.py`): Quarto 1.7.18's `quartoToggleColorScheme()` switches the stylesheets, saves the choice, then calls
`toggleGiscusIfUsed()`, which is not in scope; the throw skips the link's `return false`, so `href=""` reloads the
page. Over http the reload re-applies the saved choice (a flicker); on `file://` Quarto keeps the choice in a JS
variable and Chrome also blocks the module scripts (CORS), so the reload lands back in light. Fix: `aa-head.html`
(`include-in-header` on every page) defines a no-op `window.toggleGiscusIfUsed` before Quarto's script. After it,
the click switches in place over http and on local files, no reload. The dashboard header's own toggle is hidden in
`dashboard.css` (the site navbar keeps the one). A `jQuery is not defined` page error on the dashboard predates
this work (checked against the live site).
