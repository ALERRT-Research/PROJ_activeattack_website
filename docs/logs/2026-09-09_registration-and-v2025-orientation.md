# 2026-09-09 — Bob registration and post-v2025 orientation

Written by Bob (`/bob add`) on registering the Active Attack Data Explorer as an umbrella project.
Card: `bob.md` at repo root. Registry: `~/.claude/bob/registry-local.md` (machine-local).
Scope: three repos that together produce https://activeattackdata.org/. Nothing here was committed.

## Pipeline chain

`DATA_aa` → `PROJ_activeattack_graphics` → `PROJ_activeattack_website`, all under
`/Users/PTT2/Documents/GitHub/` and all in the `ALERRT-Research` GitHub org.

**DATA_aa** — the data build. Raw Excel `input/events/{version}/aa_data_{version}.xlsx` plus
victim rosters (`input/victims/2000_2020`, `2021`…`2024`, one Excel each) → cleaned wide/long `.rds`
with and without geography, a `codebookr`/`officer` codebook `.docx`, and `victims_{year}.rds`.
Outputs versioned under `output/{events,codebook}/{version}/` and `output/victims/`.
Scripts: `0_packages.R`, `code_events.R`, `codebook_events.R`, `code_victims.R`. R, pacman,
tidyverse, sf/tigris, zipcodeR. No renv lockfile.

**PROJ_activeattack_graphics** — every figure on the site. `0_packages.R` (version, checksum copy
from `../../DATA_aa/output/`, palettes, `save_girafe_widget()`), `plots_cartesian.R` (815 lines,
univariate/bivariate PNGs + ggiraph HTML widgets), `plots_geospatial.R` (bicolor map, rolling gif;
needs a Census API key in `~/.Renviron` for tigris), `plots_victims.R` (`victim_scroll.mp4` via
gganimate/av). No renv lockfile.

**PROJ_activeattack_website** — Quarto site. Pages: `index.qmd`, `1_visuals.qmd` (dashboard:
Timing / Attackers / Locations / Casualties / Across the USA / Fact Sheet / Download the Data),
`2_victims.qmd` (Remembrance), `3_contact.qmd`. `0_set_up.R` checksum-copies data from
`../DATA_aa` and media from `../PROJ_activeattack_graphics` into `data/` and `www/`, which are
committed so CI can render without the feeder repos; the update calls are skipped when
`GITHUB_ACTIONS == "true"`. Deploy: `.github/workflows/publish.yml` on push to `main` →
`gh-pages`; CNAME `activeattackdata.org`. `renv.lock` present (R 4.3.3, 142 packages).

Coupling is by relative path (`../`) and md5 checksum (`copy_ifelse_checksums`). All three repos
must be checked out side by side for any local render or pipeline run.

**PROJ_activeattack_app** — Shiny predecessor (same plots, `app_ui.R`/`app_server.R`), last commit
2024-10-21, the same week the website's publish workflow was created. Defunct. Peter wants it
removed (local folder + GitHub repo `ALERRT-Research/PROJ_activeattack_app`); this requires his
explicit approval in a separate step and has NOT been done.

## State on registration

Local clones were behind origin in all three repos (1 / 2 / 5 commits), all pushed by Hunter
Martaindale on 2026-09-08 and 2026-09-09. Working trees were clean; all three were brought
current with `git pull --ff-only`. Nothing pushed.

| Repo | Old HEAD | New HEAD |
|------|----------|----------|
| DATA_aa | f2116cf (2025-12-04) | 536e604 |
| PROJ_activeattack_graphics | 5f35212 (2025-08-29) | 5600a7b |
| PROJ_activeattack_website | 8a0d943 (2025-12-04) | 1bb0536 |

Deploy succeeded: `origin/gh-pages` rebuilt 2026-09-09 13:48 UTC; the live site serves
"2000 - 2025", 634 attacks, `active_attack_data_v2025` downloads, and the 09/09/26 update note.

## Hunter's upstream changes

**DATA_aa** (536e604, "Add 2025 data and run pipeline; fix Windows and geocoding issues")
- Added `input/events/2025/aa_data_2025.xlsx`; `version <- "2025"` in `code_events.R` and
  `codebook_events.R`; regenerated `output/events/2025/*` and `output/codebook/2025/*`.
- Windows fix: `system("mkdir -p …")` / `system("rm …")` → `dir.create(recursive=TRUE)` /
  `file.remove()`.
- Geocoding fix: new coverage check after the zip join — any event with empty geometry now raises
  an immediate `warning()` listing case codes, instead of silently dropping off every map.
- Comment pins `input/events/2023/zip_coords_completed.csv` as a cumulative non-ZCTA lookup that
  lives under the 2023 folder for historical reasons; do not re-point it at `{version}`.
- `.gitignore` += `Rplots.pdf`.

**PROJ_activeattack_graphics** (4e8c6ac, 5600a7b)
- `version <- "2025"`; regenerated all outputs (52 media/data files).
- New `save_girafe_widget()`: strips ggiraph ≥ 0.9's Liberation-font html dependencies before
  `saveWidget(selfcontained=TRUE)`; each widget was going from ~0.6 MB to ~9 MB. Used for the four
  interactive HTMLs.
- `set.seed(1234)` inside `generate_wound_killed_plot()` so static and interactive jitter match
  and the plot reproduces.
- Year axis `breaks = 2000:as.integer(version)` replaces hardcoded `2000:2024`.
- 2017 axis-break marker on the attacks-vs-casualties pyramid now derived from
  `which(levels(year) == "2017")` instead of fixed y = 7.25–8.75, so it stops drifting a row per
  added year.
- Victims import: if `victims_{version}.rds` is absent, falls back to the newest available
  `victims_YYYY.rds` with a warning; `plots_victims.R` uses `victims_version` throughout.

**PROJ_activeattack_website** (1dfa83f merge of `update-v2025`, fb5d236, f09bf56, 1bb0536)
- `version <- "2025"` in `0_set_up.R`, `1_visuals.qmd`, `2_victims.qmd`; refreshed 19 figures in
  `www/`; added v2025 data/codebook/csv to `data/`.
- Fact-sheet card rewritten with v2025 numbers (634 attacks; 4,287 casualties, 2,810 wounded,
  1,477 killed); horizontal rules removed; download switched from `aa_fact_sheet_template.docx`
  to a static `data/aa_fact_sheet_2025.pdf`.
- `index.qmd`: link to alerrtresearch.org added, ALERRT links reworded, Updates list extended.
- `.gitignore` += `**/*.quarto_ipynb`. `renv.lock` and the workflow were NOT touched.

## Fix items (open as of 2026-09-09)

1. **Victims memorial roster not updated to 2025.** No `DATA_aa/input/victims/2025/`, no
   `output/victims/victims_2025.rds`. Graphics fell back to v2024 by design; `victim_scroll.mp4`
   is unchanged since 2025-06-20 in both repos. `2_victims.qmd` computes its prose from event
   data, so the Remembrance page now says "Between 2000 and 2025 … 634 active attack events" above
   a video that ends at 2024. The only user-visible inconsistency on the live site. Needs the 2025
   roster from whoever at ALERRT compiles it, then `code_victims.R` → `plots_victims.R` → website.
2. **Fact-sheet numbers are hand-typed** in `1_visuals.qmd`, not computed from `aa_data`
   (pre-existing pattern). v2025 shows 2 decimals (93.22%) where v2024 showed 1 (93.3%). Cosmetic
   now; a candidate to compute during the overhaul.
3. **Orphaned files** (nothing broken, nothing referenced): `data/aa_fact_sheet_template.docx`,
   unversioned `data/aa_data_wide_codebook.docx`, v2023 and v2024 copies of every data file in
   `data/`, and `www/bivar_kill_yr.png` + `www/bivar_kill_year.html` (their update calls are
   commented out in `0_set_up.R` and no page references them). Removal needs Peter's approval.
4. **Version / lockfile fragility.** `publish.yml` pins `r-version: '4.2.0'`; `renv.lock` was
   written under R 4.3.3; Peter's Mac runs R 4.5.1 with Quarto 1.7.18. CI passed this time
   because the lock was not regenerated. `DATA_aa` and graphics have no lockfile at all, and
   Hunter's run used ggiraph ≥ 0.9 (his Windows machine); expect package drift between his
   environment and Peter's the next time the pipeline runs locally. Aging pins in the website lock:
   ggplot2 3.5.1, DT 0.33, bslib 0.8.0, rmarkdown 2.28, knitr 1.48.
5. **Remove `PROJ_activeattack_app`** — local folder and GitHub repo. Awaiting Peter's explicit
   approval.

## Later

- Visual overhaul of the site, fall 2026, before the ALERRT conference in December 2026. Not the
  current objective; scope with Hunter.
- Annual v2026 refresh: bump `version` in five places (DATA_aa ×2, graphics `0_packages.R`,
  website `0_set_up.R` / `1_visuals.qmd` / `2_victims.qmd`), add the new raw Excel and victim
  roster, run the three repos in order.

## People

- Hunter Martaindale — co-maintainer; made every upstream change above; pushes directly to `main`.
- Jack Cox (`jackdjohncox`) — former contributor (fact-sheet tab PR, 2025-12-04); no longer at
  ALERRT.
- Sibling project: Research Ring Website (`PROJ_researchring_website`, alerrtresearch.org).
