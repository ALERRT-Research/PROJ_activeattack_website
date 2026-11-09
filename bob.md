---
card_schema: bob/2
project: Active Attack Data Explorer (activeattackdata.org)
type: web
status: active
priority: high  # 11-06: update is happening before the conference
importance: medium
path: /Users/PTT2/Documents/GitHub/PROJ_activeattack_website
deadline: 2026-11-13  # site updated before the ALERRT conference, Nov 16–19 (Peter, 2026-10-16; approximate)
target: Site updated before the ALERRT conference (Nov 16–19, 2026); post-v2025 housekeeping first
effort_remaining: ~1h housekeeping + optional site-wide restyle (~3-4h); light/dark is a stretch goal
weekly_commitment: ~3h through 11-13
last_updated: 2026-11-09
blockers: null
blocking_others: null
phase: in-progress
repo: https://github.com/ALERRT-Research/PROJ_activeattack_website (+ DATA_aa, PROJ_activeattack_graphics)
sync: github
---

## Objectives

- Keep activeattackdata.org (Research Ring's public Active Attack Data site) accurate and current with each annual data version
- Umbrella card for the three-repo pipeline: `DATA_aa` (build) → `PROJ_activeattack_graphics` (figures) → `PROJ_activeattack_website` (Quarto site, GitHub Pages)
- Near term: finish housekeeping after Hunter's v2025 update; then: update the site before the ALERRT conference, Nov 16–19, 2026 (deadline ~11-13)

## Team & Dependencies

| Name | Role | Affiliation | Waiting on Peter? |
|------|------|-------------|-------------------|
| Hunter Martaindale | Co-maintainer; did the v2025 data update and pipeline fixes (Windows) | ALERRT / Texas State | No |
| Jack Cox | Former contributor (fact-sheet tab, 2025) — no longer at ALERRT | — | No |

## This Week

- [x] **Fact sheet retool** done 11-06 (web tab + 2-page Typst PDF + latest-year map), pushed; live once the runner-pin deploy succeeds. PDF rebuild: `Rscript R/fact_sheet_pdf.R`; map: graphics `code/plots_latest_year_map.R`. See `docs/logs/2026-11-06_fact-sheet-stats-and-data-fix.md`
- [x] **Site-wide look** done and pushed 11-06: page styling, figures (refined, muted palette), maps, tab headers/chart-first layout, map-led landing page, Remembrance names page; all live 11-06. **Contact page** (11-09, live) and **Download the Data tab**, **Codebook page + PDF** and a **suggested citation** (11-09, committed, not pushed; `docs/logs/2026-11-09_download-tab.md`, `2026-11-09_codebook.md`) in the new style. Next: light/dark (stretch)
- [ ] Tell Hunter: victims list vs events deaths differ by year (2016 88 vs 81, 2017 149 vs 147, 2024 29 vs 32; 13 rows unnamed), see log 11-06; scope settled; DATA_aa relationship recode fix + church/military base levels (11-06, `docs/logs/2026-11-06_fact-sheet-stats-and-data-fix.md`); 09-09 fixes; ggiraph 0.9.6 pin
- Delete `ALERRT-Research/PROJ_activeattack_app` on GitHub (local clone already removed 2026-09-24). Blocked on Peter's side: needs `gh auth refresh -h github.com -s delete_repo` in a real terminal AND admin on the org repo (API returned 403 without it); web UI under repo Settings is the fallback, or ask Hunter if he owns the org

## Upcoming Milestones

- **~2026-11-13: site updated** before the ALERRT conference, **Nov 16–19, 2026** (was recorded as December — corrected 2026-10-16). Scope with Hunter now; a full overhaul may not fit around IACP and the biosocial course. Includes native light/dark toggle for the whole site AND every visualization (two variants of each figure; Pete favours dark, high-contrast; `bw=` switch in graphics `plots_cartesian.R` is the prototype) — see `docs/logs/2026-09-10_dark-plot-side-quest-and-theming-note.md`
- Annual: v2026 data refresh (~mid-year, after FBI active-shooter report cycle); bump `version <- "2026"` in DATA_aa (2 scripts), graphics `0_packages.R`, website `0_set_up.R` + `1_visuals.qmd` + `2_victims.qmd`

## Backlog (after the conference; Peter and Hunter, 2026-11-09)

- **Derivative datasets to post**, each with a download and a short page: (1) the **SIA door-locks dataset** built from the Active Attack data for the SIA grant; (2) the **officers-shot dataset** (Hunter's update): Active Attack data to find cases where officers were shot, cross-referenced to LEOKA for detail. Ask Hunter where both live and which versions are releasable
- **Publications page**: every article that used the Active Attack data, plus a way for the public to tell us about their own papers, presentations and projects that used it (collect, then list them)
- **DOI + dataset profile** (Peter, 11-09): mint a DOI per data version (Zenodo or the TXST repository) and publish a data-descriptor paper profiling the dataset, so we and others cite one fixed record while the publications page collects the cites
- **Victim scroll video**: same structure (short front matter for context, then the names scrolling), sharper look to match the site

## Start Here Next Session

- Run `git -C <repo> status -sb` in all three sibling repos; if behind, `git pull --ff-only` (Hunter pushes directly to main)
- Unpushed: website (Download tab, Codebook, backlog), DATA_aa (label fix + labels CSV export); graphics in sync
- **Fetch before rendering**: `git fetch` + `pull --ff-only` in all three repos first. A behind DATA_aa clone silently reverted the 11-06 data fix through the checksum refresh (11-09, caught before push; `docs/logs/2026-11-09_codebook.md`). `AA_SKIP_UPDATE=1` skips the refresh if a feeder is known to be behind
- Codebook rebuild after a data update: `Rscript R/codebook_pdf.R` (page renders itself); labels come from DATA_aa's `codebook_events.R`
- On this Mac render the site with `RENV_CONFIG_AUTOLOADER_ENABLED=FALSE quarto render ...` (project renv library is nearly empty)
- Never render `1_visuals.qmd`/`2_victims.qmd` locally without `../DATA_aa` and `../PROJ_activeattack_graphics` checked out beside this repo
- Push requires Peter's explicit approval; deploy is automatic on push to `main`

## Notes

- Pipeline coupling: relative `../` paths + md5 checksum copies (`copy_ifelse_checksums`). All three repos must sit as siblings under `~/Documents/GitHub/`. Website `data/` and `www/` are committed so GitHub Actions renders without the feeders (update calls are skipped when `GITHUB_ACTIONS == "true"`)
- Deploy: `.github/workflows/publish.yml` on push to `main` → `gh-pages`; CNAME `activeattackdata.org`. Runner pins R 4.2.0 while `renv.lock` was written under R 4.3.3 and Peter's Mac runs 4.5.1 — works today, fragile if the lock is regenerated
- Only the website has an `renv.lock`; `DATA_aa` and graphics have none. Graphics `0_packages.R` pins ggiraph 0.9.6 since 2026-09-24 (Peter's Mac was on 0.9.0, R 4.5.1, ggplot2 4.0.3; Hunter already on 0.9.6). `opts_toolbar(saveaspng=FALSE)` alone no longer hides download/fullscreen in ggiraph ≥ 0.9; use `hidden = c("selection","zoom","misc")` (applied to all four widgets)
- Graphics `output/*_files/` and `.DS_Store` untracked + gitignored 2026-09-24 (59 files; `saveWidget` staging, widgets are self-contained). Dirs still on disk, harmless
- Fact sheet is computed: `R/fact_sheet_stats.R` (numbers), `R/fact_sheet_html.R` (tab), `R/fact_sheet_pdf.R` (PDF, local only, committed). Peter built and owns the website and graphics repos. `aa_fact_sheet_template.docx` and unversioned `aa_data_wide_codebook.docx` are orphaned, as are the v2023/v2024 data copies in `data/` and `bivar_kill_yr.png`/`bivar_kill_year.html` in `www/`
- `zip_coords_completed.csv` lives under `input/events/2023/` on purpose — cumulative non-ZCTA lookup, do not re-point at `{version}`; `code_events.R` warns on any event that fails to geocode
- Site policy: never name attackers (Don't Name Them); Remembrance page lists victims only
- Sibling project: Research Ring Website (`PROJ_researchring_website`) — index.qmd links to alerrtresearch.org
- Orientation (pipeline, Hunter's v2025 changes, fix items, env fragility): `docs/logs/2026-09-09_registration-and-v2025-orientation.md`; fixes: `docs/logs/2026-09-09_weapon-plot-and-toolbar-fixes.md`; prune history: `docs/logs/2026-09-24_bob-prune.md`

<!-- Budget: ≤ 150 lines total. History lives in docs/logs/, conventions in CLAUDE.md. -->
