# 2026-11-06: Fact sheet stats script; relationship/location data fix

Step 1 of `plans/2026-11-06_fact-sheet-retool.md`.

## Done

- `R/fact_sheet_stats.R`: every fact-sheet number computed from the wide data, plus 2024, 2025, change, and
  the 2020-24 per-year average. `R/check_fact_sheet_v2025.R` reconciles against the hand-typed v2025 sheet:
  **43/43 reproduce** after the fix below (39/43 before).
- Reconciliation exposed two DATA_aa issues, fixed with Peter's approval:
  - `code_events.R` relationship recode matched `"former employee/co-worker"`, but the raw sheet spells it
    `"former employee/coworker"`: 33 events fell into "other". Released CSV, codebook and relationship figure
    undercounted coworkers (66 → 99; other 40 → 7). The published fact sheet was already right (built from the
    raw xlsx).
  - Church (22) and military base (7) kept as their own `location_primary` levels (same reasoning as medical
    facility, 09-14).
- Pipeline rerun on Peter's Mac: only `location_primary` and `relationship` changed (geometry diff 7e-9 deg,
  float noise). Codebook regenerated.
- Graphics: `plots_cartesian.R` folds church/military base back into "Other" so location figures are unchanged.
  Only `univar_rel.png` and `bivar_loctype_rel.png` kept from the rerun; every other figure differed only by
  Mac-vs-Windows rendering and was reverted.
- Website: `1_visuals.qmd` "Other" location text now counts Other + Church + Military base (would otherwise
  have dropped 91 → 62); missing `%` added in the coworker sentence; `index.qmd` changelog entry. Local render
  of `1_visuals.qmd` checked.

## Later the same day: steps 2 and 3

- Step 2: Fact Sheet tab rebuilt from `R/fact_sheet_stats.R` via `R/fact_sheet_html.R`; hand-typed list removed.
  `1_visuals.qmd` is `format: dashboard`, which does NOT inherit `format: html` css from `_quarto.yml`; the page
  now links `dashboard.css`. The downloadthis extension caps buttons at 125px with an ellipsis (overridden).
- Step 3: design direction approved (`plans/2026-11-06_fact-sheet-design.md`); built and checked at 375-1400px.

## Still to do

- Tell Hunter: the recode fix and new location levels. (Correction 11-06: the graphics pipeline and site are
  Peter's, not Hunter's.) A Windows render of graphics would re-byte the reverted figures, which is harmless.
- Plan steps 4-5 (Typst PDF in the same design, wire-up). Light/dark toggle and site-wide rollout after the conference.
- Data fix pushed 11-06 (all three repos); steps 2-3 committed locally, not pushed.

## Step 4: PDF

- `R/fact_sheet_pdf.R` writes Typst from `fact_sheet_stats()` and compiles it with Quarto's bundled Typst 0.11
  (`Rscript R/fact_sheet_pdf.R`), overwriting `data/aa_fact_sheet_2025.pdf` (the hand-made v2025 sheet is in git
  history). Two letter pages, same tokens as the web tab; keeps the 2024 column. Not part of the site render.
- Static Public Sans (OFL) in `fact_sheet/fonts/`: Typst 0.11 sees only the Thin instance of the installed
  variable font. Generated `.typ` is gitignored.
- Web tab revisions the same day: bars on a shared zero line, maroon `#9E1B32`, 2024 column dropped from web tables,
  "One weapon" row added (weapon_tot <= 1; 18 attacks with weapon_tot 0 are vehicle/unknown-firearm attacks).
- Latest-year map added beside the headline boxes (boxes now 2 x 2), web and PDF:
  `PROJ_activeattack_graphics/code/plots_latest_year_map.R` -> `output/map_latest_year.svg` -> `www/` via
  `update_aa_graphics()`. One maroon dot per attack, plain outlines, no sizing or shading. The script sets the tigris
  cache with `Sys.setenv()`; `tigris_cache_dir()` (used in `plots_geospatial.R`) rewrites `~/.Renviron` each run.

## Deploy outage and site-wide look (evening)

- Every deploy on 11-06 failed until the runner pin: `ubuntu-latest` became Ubuntu 26.04, the locked `later` would
  not compile under R 4.2.0, and the renv cache (keyed by OS) missed. `runs-on: ubuntu-24.04` fixed it; live from
  the 2071508 deploy. `bob.md` had been published as `bob.html` since it was added; the site now renders `*.qmd` only
  (verified 404 live).
- Part A (website): `aa-theme.css` holds the tokens (`--aa-*`), Public Sans, links, buttons and TOC; loaded by
  `_quarto.yml` and `1_visuals.qmd`. Dashboard cards and card tabsets restyled on every tab.
- Part B (graphics): `0_packages.R` defines the palette (slate single series, maroon latest year, `rel_pal` for the
  one categorical chart, validated with the dataviz script) and wraps the cowplot/ggplot themes with Public Sans.
  Static fonts in `fonts/` are registered as "AA Public Sans" (the installed variable font renders Thin, and
  systemfonts refuses to re-register an installed family). Rscript's pdf() device cannot resolve the font, so bare
  plot prints go to ragg. Ridges at `scale = 1` (one colour would merge overlapping rows). Casualties pyramid:
  attacks slate, fatalities ink, wounded light. All figures re-rendered and committed.
- Not restyled: the two dark maps (bivariate choropleth, rolling GIF). The race figure counts every attacker
  (300 Caucasian) while the fact sheet uses the first-listed attacker (299); both are right, but they differ.
- Revised the same evening after Peter's review ("dull and in places garish"; tabs looked like they sat in the plot):
  one colour per tab again, palette B chosen from a preview (Timing ochre #b06f1a, Attackers blue #2a63a8,
  Locations green #378a62, Casualties violet #9070cc; validator all-pairs pass). Ochre, not the old vermilion,
  because a maroon latest-year bar disappears in vermilion. The relationship chart uses the tab colours + grey.
  Card tabsets now sit on a grey band with folder-style tabs.
- Grouped charts got shades of the tab colour per group (validated families); interactive widgets now fill their
  iframe (no 960px default, no padding; iframe at the plot's 10:7 shape), so no scrollbars at any width.
- Maps restyled to match the Fact Sheet map: pale land, white borders, Public Sans. State map is a teal (attacks) x
  violet (fatalities) bivariate; **bug fixed**: states with no attacks (Delaware) counted as 1 attack after the
  full_join (`n()`), now `sum(!is.na(year))`; Puerto Rico dropped. Rolling GIF is light, weapon in tab colours,
  legend titled, rendered with ragg (the default png device dropped all text). Widgets swap the R font name for the
  web font and embed Public Sans.
