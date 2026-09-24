---
project: Active Attack Data Explorer (activeattackdata.org)
type: web
status: active
priority: medium
importance: medium
path: /Users/PTT2/Documents/GitHub/PROJ_activeattack_website
deadline: null
target: Post-v2025 housekeeping (quick); visual overhaul before ALERRT conference Dec 2026
effort_remaining: ~2h housekeeping (untrack lib dirs, orphans, version pins); overhaul unscoped
weekly_commitment: 1h
last_updated: 2026-09-24
blockers: null
blocking_others: null
phase: in-progress
repo: https://github.com/ALERRT-Research/PROJ_activeattack_website (+ DATA_aa, PROJ_activeattack_graphics)
sync: github
---

## Objectives

- Keep activeattackdata.org (Research Ring's public Active Attack Data site) accurate and current with each annual data version
- Umbrella card for the three-repo pipeline: `DATA_aa` (build) → `PROJ_activeattack_graphics` (figures) → `PROJ_activeattack_website` (Quarto site, GitHub Pages)
- Near term: finish housekeeping after Hunter's v2025 update; later: visual overhaul of the site for the December 2026 ALERRT conference

## Team & Dependencies

| Name | Role | Affiliation | Waiting on Peter? |
|------|------|-------------|-------------------|
| Hunter Martaindale | Co-maintainer; did the v2025 data update and pipeline fixes (Windows) | ALERRT / Texas State | No |
| Jack Cox | Former contributor (fact-sheet tab, 2025) — no longer at ALERRT | — | No |

## This Week

- Get Peter's explicit approval to (a) untrack `output/*_files/` + `.DS_Store` in the graphics repo and (b) remove the defunct Shiny app `PROJ_activeattack_app` (local folder + GitHub repo) — not actioned until he says so
- Tell Hunter about the 09-09 fixes and the ggiraph 0.9.1 (Mac) vs 0.9.6 (Windows) drift; agree on pinning

## Upcoming Milestones

- Fall 2026 (TBD): visual overhaul of the site — scope with Hunter; must land before the ALERRT conference, December 2026. Includes native light/dark toggle for the whole site AND every visualization (two variants of each figure; Pete favours dark, high-contrast; `bw=` switch in graphics `plots_cartesian.R` is the prototype) — see `docs/logs/2026-09-10_dark-plot-side-quest-and-theming-note.md`
- Annual: v2026 data refresh (~mid-year, after FBI active-shooter report cycle); bump `version <- "2026"` in DATA_aa (2 scripts), graphics `0_packages.R`, website `0_set_up.R` + `1_visuals.qmd` + `2_victims.qmd`

## Start Here Next Session

- Run `git -C <repo> status -sb` in all three sibling repos; if behind, `git pull --ff-only` (Hunter pushes directly to main)
- Nothing user-visible is wrong on the live site; the work is the two This Week items, then the OPEN items in Notes
- Never render `1_visuals.qmd`/`2_victims.qmd` locally without `../DATA_aa` and `../PROJ_activeattack_graphics` checked out beside this repo
- Push requires Peter's explicit approval; deploy is automatic on push to `main`

## Notes

- Pipeline coupling: relative `../` paths + md5 checksum copies (`copy_ifelse_checksums`). All three repos must sit as siblings under `~/Documents/GitHub/`. Website `data/` and `www/` are committed so GitHub Actions renders without the feeders (update calls are skipped when `GITHUB_ACTIONS == "true"`)
- Deploy: `.github/workflows/publish.yml` on push to `main` → `gh-pages`; CNAME `activeattackdata.org`. Runner pins R 4.2.0 while `renv.lock` was written under R 4.3.3 and Peter's Mac runs 4.5.1 — works today, fragile if the lock is regenerated
- Only the website has an `renv.lock`; `DATA_aa` and graphics have none. Hunter renders with ggiraph 0.9.6 (Windows), Peter with 0.9.1 (Mac, R 4.5.1, ggplot2 4.0.3) — both work, bytes differ. `opts_toolbar(saveaspng=FALSE)` alone no longer hides download/fullscreen in ggiraph ≥ 0.9; use `hidden = c("selection","zoom","misc")` (applied to all four widgets)
- OPEN (graphics repo): `output/*_files/` dirs are `saveWidget` staging leftovers, tracked since 2024-11, holding both ggiraph 0.8.10 and 0.9.4 libs (~2 MB) plus a tracked `output/.DS_Store`. Widgets are fully self-contained. Fix: `save_girafe_widget()` deletes the sibling dir; untrack + gitignore (deletion → approval)
- OPEN (v2025): fact-sheet numbers in `1_visuals.qmd` are hand-typed, not computed from the data; now 2 decimals where v2024 used 1. Fact sheet is a static `data/aa_fact_sheet_2025.pdf`; `aa_fact_sheet_template.docx` and unversioned `aa_data_wide_codebook.docx` are orphaned, as are the v2023/v2024 data copies in `data/` and `bivar_kill_yr.png`/`bivar_kill_year.html` in `www/`
- `zip_coords_completed.csv` lives under `input/events/2023/` on purpose — cumulative non-ZCTA lookup, do not re-point at `{version}`; `code_events.R` warns on any event that fails to geocode
- Site policy: never name attackers (Don't Name Them); Remembrance page lists victims only
- TO-DO (needs Peter's explicit approval, not done): `PROJ_activeattack_app` (Shiny predecessor, last commit 2024-10-21) is defunct — remove local folder and GitHub repo `ALERRT-Research/PROJ_activeattack_app`
- Sibling project: Research Ring Website (`PROJ_researchring_website`) — index.qmd links to alerrtresearch.org
- Orientation (pipeline, Hunter's v2025 changes, fix items, env fragility): `docs/logs/2026-09-09_registration-and-v2025-orientation.md`; fixes: `docs/logs/2026-09-09_weapon-plot-and-toolbar-fixes.md`; prune history: `docs/logs/2026-09-24_bob-prune.md`

<!-- Budget: ≤ 150 lines total. History lives in docs/logs/, conventions in CLAUDE.md. -->
