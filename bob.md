---
project: Active Attack Data Explorer (activeattackdata.org)
type: web
status: active
priority: medium
importance: medium
path: /Users/PTT2/Documents/GitHub/PROJ_activeattack_website
deadline: null
target: Post-v2025 fixes (quick, Hunter did the heavy lifting); visual overhaul before ALERRT conference Dec 2026
effort_remaining: ~3h for the post-v2025 fixes; overhaul unscoped
weekly_commitment: 1h
last_updated: 2026-09-09
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

- Confirm Peter's local clones match origin (done 2026-09-09 — all three fast-forwarded; live site is v2025)
- Decide with Hunter: 2025 victim memorial roster — who supplies it, when. Until then the Remembrance page text says 2000–2025 but `victim_scroll.mp4` is still the v2024 roll
- Ask Peter for explicit approval to remove the defunct Shiny app (`PROJ_activeattack_app`: local folder + GitHub repo)

## Upcoming Milestones

- Fall 2026 (TBD): visual overhaul of the site — scope with Hunter; must land before the ALERRT conference, December 2026
- Annual: v2026 data refresh (~mid-year, after FBI active-shooter report cycle); bump `version <- "2026"` in DATA_aa (2 scripts), graphics `0_packages.R`, website `0_set_up.R` + `1_visuals.qmd` + `2_victims.qmd`

## Start Here Next Session

- Run `git -C <repo> status -sb` in all three repos; if behind, `git pull --ff-only` (Hunter pushes directly to main)
- Then work the open v2025 items in Notes below, victims roster first — it is the only user-visible inconsistency on the live site
- Never render `1_visuals.qmd`/`2_victims.qmd` locally without the sibling repos checked out beside this one; the update functions copy from `../DATA_aa` and `../PROJ_activeattack_graphics`
- Push requires Peter's explicit approval; deploy is automatic on push to `main`

## Notes

- Pipeline coupling: relative `../` paths + md5 checksum copies (`copy_ifelse_checksums`). All three repos must sit as siblings under `~/Documents/GitHub/`. Website `data/` and `www/` are committed so GitHub Actions renders without the feeders (update calls are skipped when `GITHUB_ACTIONS == "true"`)
- Deploy: `.github/workflows/publish.yml` on push to `main` → `gh-pages`; CNAME `activeattackdata.org`. Runner pins R 4.2.0 while `renv.lock` was written under R 4.3.3 and Peter's Mac runs 4.5.1 — works today, fragile if the lock is regenerated
- Only the website has an `renv.lock`; `DATA_aa` and graphics have none. Hunter's v2025 run used ggiraph ≥ 0.9 (hence the new `save_girafe_widget()` font-stripping helper); expect environment drift between his Windows box and Peter's Mac
- OPEN (v2025): no `DATA_aa/input/victims/2025/` and no `victims_2025.rds`; graphics falls back to v2024 by design and `victim_scroll.mp4` is unchanged since 2025-06-20. Remembrance prose (computed from event data) says 2000–2025; the video ends at 2024
- OPEN (v2025): fact-sheet numbers in `1_visuals.qmd` are hand-typed, not computed from the data; now 2 decimals where v2024 used 1. Fact sheet is a static `data/aa_fact_sheet_2025.pdf`; `aa_fact_sheet_template.docx` and unversioned `aa_data_wide_codebook.docx` are orphaned, as are the v2023/v2024 data copies in `data/` and `bivar_kill_yr.png`/`bivar_kill_year.html` in `www/`
- `zip_coords_completed.csv` lives under `input/events/2023/` on purpose — cumulative non-ZCTA lookup, do not re-point at `{version}`; `code_events.R` now warns on any event that fails to geocode
- Site policy: never name attackers (Don't Name Them); Remembrance page lists victims only
- TO-DO (needs Peter's explicit approval, not done): `PROJ_activeattack_app` (Shiny predecessor, last commit 2024-10-21) is defunct — remove local folder and GitHub repo `ALERRT-Research/PROJ_activeattack_app`
- Sibling project: Research Ring Website (`PROJ_researchring_website`) — index.qmd now links to alerrtresearch.org
- Full orientation (pipeline, Hunter's v2025 changes, fix items, env fragility): `docs/logs/2026-09-09_registration-and-v2025-orientation.md`

<!-- Budget: ≤ 150 lines total. History lives in docs/logs/, conventions in CLAUDE.md. -->
