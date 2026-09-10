---
project: Active Attack Data Explorer (activeattackdata.org)
type: web
status: active
priority: medium
importance: medium
path: /Users/PTT2/Documents/GitHub/PROJ_activeattack_website
deadline: null
target: Post-v2025 fixes (quick, Hunter did the heavy lifting); visual overhaul before ALERRT conference Dec 2026
effort_remaining: ~2h housekeeping (untrack lib dirs, orphans, version pins); overhaul unscoped
weekly_commitment: 1h
last_updated: 2026-09-10
blockers: null
blocking_others: null
phase: in-progress
repo: https://github.com/ALERRT-Research/PROJ_activeattack_website (+ DATA_aa, PROJ_activeattack_graphics)
sync: github
---

## Objectives

- Keep activeattackdata.org (Research Ring's public Active Attack Data site) accurate and current with each annual data version
- Umbrella card for the three-repo pipeline: `DATA_aa` (build) → `PROJ_activeattack_graphics` (figures) → `PROJ_activeattack_website` (Quarto site, GitHub Pages)
- Near term: verify and tidy after Hunter's v2025 update (2026-09-08/09); later: visual overhaul of the site for the December 2026 ALERRT conference

## Team & Dependencies

| Name | Role | Affiliation | Waiting on Peter? |
|------|------|-------------|-------------------|
| Hunter Martaindale | Co-maintainer; did the v2025 data update and pipeline fixes (Windows) | ALERRT / Texas State | No |
| Jack Cox | Former contributor (fact-sheet tab, 2025) — no longer at ALERRT | — | No |

## This Week

- DONE 2026-09-09: clones current; weapon-plot arrow colour + dropped zero-count points fixed; toolbar icons hidden on all four widgets; deployed and verified live — see `docs/logs/2026-09-09_weapon-plot-and-toolbar-fixes.md`
- DONE 2026-09-09 (Hunter): 2025 victim memorial roster added, scroll regenerated, deployed
- DONE 2026-09-10: dark-theme wounded/killed dotplot for Pete (graphics `bw=` switch), pushed; light/dark theming logged as overhaul requirement
- Ask Peter for explicit approval to (a) untrack `output/*_files/` + `.DS_Store` in graphics and (b) remove the defunct Shiny app (`PROJ_activeattack_app`: local folder + GitHub repo)
- Tell Hunter about the two fixes and the ggiraph 0.9.1 (Mac) vs 0.9.6 (his) drift; agree on pinning

## Upcoming Milestones

- Fall 2026 (TBD): visual overhaul of the site — scope with Hunter; must land before the ALERRT conference, December 2026. Includes native light/dark toggle for the whole site AND every visualization (two variants of each figure; Pete favours dark, high-contrast) — see `docs/logs/2026-09-10_dark-plot-side-quest-and-theming-note.md`
- Annual: v2026 data refresh (~mid-year, after FBI active-shooter report cycle); bump `version <- "2026"` in DATA_aa (2 scripts), graphics `0_packages.R`, website `0_set_up.R` + `1_visuals.qmd` + `2_victims.qmd`

## Start Here Next Session

- Run `git -C <repo> status -sb` in all three repos; if behind, `git pull --ff-only` (Hunter pushes directly to main)
- Then work the OPEN items in Notes below; nothing user-visible is currently wrong on the live site
- Never render `1_visuals.qmd`/`2_victims.qmd` locally without the sibling repos checked out beside this one; the update functions copy from `../DATA_aa` and `../PROJ_activeattack_graphics`
- Push requires Peter's explicit approval; deploy is automatic on push to `main`

## Notes

- Pipeline coupling: relative `../` paths + md5 checksum copies (`copy_ifelse_checksums`). All three repos must sit as siblings under `~/Documents/GitHub/`. Website `data/` and `www/` are committed so GitHub Actions renders without the feeders (update calls are skipped when `GITHUB_ACTIONS == "true"`)
- Deploy: `.github/workflows/publish.yml` on push to `main` → `gh-pages`; CNAME `activeattackdata.org`. Runner pins R 4.2.0 while `renv.lock` was written under R 4.3.3 and Peter's Mac runs 4.5.1 — works today, fragile if the lock is regenerated
- Only the website has an `renv.lock`; `DATA_aa` and graphics have none. Hunter renders with ggiraph 0.9.6 (Windows), Peter with 0.9.1 (Mac, R 4.5.1, ggplot2 4.0.3) — both work, bytes differ. `opts_toolbar(saveaspng=FALSE)` alone no longer hides download/fullscreen in ggiraph ≥ 0.9; use `hidden = c("selection","zoom","misc")` (now applied to all four widgets)
- OPEN (graphics repo): `output/*_files/` dirs are `saveWidget` staging leftovers, tracked since 2024-11, now holding both ggiraph 0.8.10 and 0.9.4 libs (~2 MB) plus a tracked `output/.DS_Store`. Widgets themselves are fully self-contained. Fix: `save_girafe_widget()` deletes the sibling dir; untrack + gitignore (deletion → approval)
- OPEN (v2025): fact-sheet numbers in `1_visuals.qmd` are hand-typed, not computed from the data; now 2 decimals where v2024 used 1. Fact sheet is a static `data/aa_fact_sheet_2025.pdf`; `aa_fact_sheet_template.docx` and unversioned `aa_data_wide_codebook.docx` are orphaned, as are the v2023/v2024 data copies in `data/` and `bivar_kill_yr.png`/`bivar_kill_year.html` in `www/`
- `zip_coords_completed.csv` lives under `input/events/2023/` on purpose — cumulative non-ZCTA lookup, do not re-point at `{version}`; `code_events.R` now warns on any event that fails to geocode
- Site policy: never name attackers (Don't Name Them); Remembrance page lists victims only
- TO-DO (needs Peter's explicit approval, not done): `PROJ_activeattack_app` (Shiny predecessor, last commit 2024-10-21) is defunct — remove local folder and GitHub repo `ALERRT-Research/PROJ_activeattack_app`
- Sibling project: Research Ring Website (`PROJ_researchring_website`) — index.qmd now links to alerrtresearch.org
- 2026-09-10: dark-theme wounded/killed dotplot for Pete via new `bw=` switch in graphics `plots_cartesian.R` (uncommitted; prototype for the two-variant plan) — same log as above
- Full orientation (pipeline, Hunter's v2025 changes, fix items, env fragility): `docs/logs/2026-09-09_registration-and-v2025-orientation.md`; today's fixes: `docs/logs/2026-09-09_weapon-plot-and-toolbar-fixes.md`

<!-- Budget: ≤ 150 lines total. History lives in docs/logs/, conventions in CLAUDE.md. -->
