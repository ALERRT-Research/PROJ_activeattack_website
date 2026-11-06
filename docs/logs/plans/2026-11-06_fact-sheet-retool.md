# Fact sheet retool: web page + PDF with a year-over-year column

**Status:** APPROVED 2026-11-06 with decisions below (page stays a tab in `1_visuals.qmd`)
**Target:** before the ALERRT conference (Nov 16-19); site deadline ~2026-11-13

## Goal

Keep every number on the current fact sheet, present it better, and add the "how are we doing versus
last year" comparison that readers actually want. Two outputs from one source of numbers:

1. A fact sheet page on the website (replaces the hand-typed bullet list in `1_visuals.qmd` § Fact Sheet)
2. A downloadable PDF (replaces the Word-built `data/aa_fact_sheet_2025.pdf`)

This also closes the OPEN item in bob.md: the numbers stop being hand-typed.

## What exists now

- `1_visuals.qmd` lines ~577-700: a "Fact Sheet" dashboard tab with a download button and a ~100-line
  hand-typed bullet list (counts + percents to 2 decimals).
- `data/aa_fact_sheet_2025.pdf`: two pages of plain Times New Roman bullet text built from
  `aa_fact_sheet_template.docx`.
- Content blocks: total attacks; primary weapon (firearm/blade/vehicle) + multiple weapons + firearm
  breakdown; number of attackers; attacker race; attacker-victim relationship; location; resolution
  (pre-/post-LE split, 8 sub-outcomes); victims (total/wounded/killed + medians).
- Spot-checked against `aa_data_wide_nogeo_2025.rds`: values match (multiple weapons 30.28%, wounded 2,810,
  killed 1,477).

## Design

### One source of numbers

New script `R/fact_sheet_stats.R` (sourced, not a page): takes the wide data and `version`, returns one tidy
table, one row per fact-sheet line:

| section | item | n_all | pct_all | n_prev | n_curr | change |
|---------|------|-------|---------|--------|--------|--------|

- `n_all`/`pct_all`: 2000-through-current cumulative (today's content).
- `n_curr` = the latest full year (2025); `n_prev` = the year before (2024). **Both come from the current data
  version**, not from last year's file, so cases added after the fact are counted in the right year.
  (Checked: the 2024 count did not change between versions, 29 events either way, but the rule protects
  future years.)
- Category mappings (e.g. Business = Office + Factory/warehouse + Retail + Medical facility; the "All Other"
  pools) live in this script once, so the page, the PDF and the existing `1_visuals.qmd` text use the same
  definitions.
- A reconciliation check: on first run, `stopifnot()` the cumulative columns against today's hand-typed
  values, so the switch from typed to computed numbers changes nothing silently.

Reused next year by bumping `version`; nothing else to edit.

### The year-over-year column: what to show

Single years are small (2024: 29 attacks; 2025: 37). That drives three choices:

- **Show counts, not shares, for the two single years.** A 2-attack swing in a 29-event year moves a
  percentage by ~7 points, which reads like a trend and isn't. Change is shown as a signed count (`+8`).
  Percentages stay on the cumulative column, where n = 634 supports them.
- **Headline tiles get the comparison front and center:** attacks, killed, wounded, and % resolved before
  LE arrival, each as "2025 vs 2024" with an up/down marker.
- **Recommended addition: the prior 5-year average as context** (2020-2024 mean, ~46 attacks/yr). 2025's 37 is
  up on 2024 but below the recent average; showing only the one-year change would tell readers the
  problem is getting worse when the longer view says otherwise. One extra column on the tiles, optional on
  the detail tables.
- Neutral colors for change (no red/green). More attacks being "up" is bad, but more civilian
  interventions being "up" is not, so a sign color would mislead in half the rows.

### Web page

Stays as the **Fact Sheet tab in `1_visuals.qmd`** (Peter, 2026-11-06), so `#fact-sheet` links keep working.
The hand-typed bullet card is replaced by: the PDF download card, a row of dashboard value boxes (the
headline 2025 vs 2024 vs 5-yr average comparison), then one card per section (Weapons, Attackers,
Locations, Resolution, Victims) holding a compact table. Tables are `knitr::kable()` + site CSS: **no new R
packages**, so `renv.lock` and the R 4.2.0 CI runner are untouched (bob.md flags that combination as
fragile). A separate page remains an option later.

### PDF

New `fact_sheet_pdf.qmd` rendered to **Typst** (bundled with Quarto 1.6.42 on this Mac; no LaTeX).
Two pages, letter: page 1 headline tiles + Weapons + Attackers; page 2 Locations + Resolution + Victims,
plus a data note (sources, ALERRT vs FBI inclusive definition, date of data version). ALERRT/Research Ring
branding from `www/`. Pulls from the same `R/fact_sheet_stats.R`.

**Rendered locally and committed** as `data/aa_fact_sheet_{version}.pdf`, same as today, so CI never needs
to render it. Excluded from the site build (`_quarto.yml` render list or a leading `_`).

## Files

| File | Change |
|------|--------|
| `R/fact_sheet_stats.R` | new: computes the tidy fact table |
| `fact_sheet_pdf.qmd` | new: Typst PDF source |
| `styles.css` | tile and table styles |
| `_quarto.yml` | keep the PDF source out of the site render |
| `1_visuals.qmd` | Fact Sheet tab rebuilt from computed tables; hand-typed list removed |
| `index.qmd` | changelog line |
| `data/aa_fact_sheet_2025.pdf` | regenerated |
| `data/aa_fact_sheet_template.docx` | orphaned once done; archive or delete (ask) |

## Order of work

1. `R/fact_sheet_stats.R` + reconciliation check against today's numbers (~1.5h)
2. Web page, unstyled, numbers correct (~1h)
3. Styling: tiles, tables, mobile (~1.5h)
4. Typst PDF (~2h, the uncertain one; fallback is a styled HTML page printed to PDF via headless Chrome)
5. Wire-up: index changelog, local full render (~0.5h)

About 6-7h total, a bit over the 4-6h in bob.md. Steps 1-2 + a plain PDF are the floor for the conference;
styling can follow.

## Verification

- Reconciliation `stopifnot()` passes (computed cumulative = current published values)
- Hand-check 2024/2025 columns for three rows against `count()` on the raw data
- Full local `quarto render` with sibling repos present; zero `#| ` leakage, navbar links resolve
- PDF: page count = 2, open and eyeball; check text extracts (accessibility)
- Mobile width screenshot of the page
- Push only on Peter's approval (push = deploy)

## Decisions (Peter, 2026-11-06)

1. Comparison: latest full year vs the year before (2025 vs 2024), both from the current data version.
2. Prior 5-year average: in, for now.
3. Placement: stays a tab in Active Attacks (`1_visuals.qmd`), not a separate page, for now.
