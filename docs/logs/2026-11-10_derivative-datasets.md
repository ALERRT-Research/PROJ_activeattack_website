# 2026-11-10: Derivative datasets located; K-12 door file structure decided

Hunter replied (from a hotel) to Peter's question about the SIA data issues.

## What Hunter reported

- Renamed `sia_data` to `k12_door_security` (shared research drive, `data/raw_data/k12_door_security/`); it will
  not be an SIA project going forward.
- The "known issues" came from his coding agent's check of the data; all minor, now fixed, codebook updated. The
  codebook was written for the SIA handover and describes extra CSVs for replicating their plots and tables, which
  the website does not need.
- Two v2025 files (CSV + RDS): events (54 attacks x 150 columns, wide, with door slots `door_*_1` to `_5`) and doors
  (66 doors x 27 columns, long). The doors file is derived entirely from the events file.
- He had already built the officer shot dataset and a codebook: `data/raw_data/officer_shot/` (xlsx only, plus
  codebook PDF, v2025, dated 2026-09-29).

## Checked

- The wide door slots are ragged (`door_glass_type` only in slots 1 and 3; `door_barricade_yes` missing from slot 5).
  The doors file also carries derived fields the wide file lacks (`door_lock_group`, `door_status_group`,
  `mechanical_breach`, `door_material_1-3`), so dropping the wide slots loses nothing.

## Decided (Peter)

- Post as two datasets, events and doors, linked by `case_number` only. No other overlapping variables: drop the
  door slots from events, and `school_level_group` and `total_victims` from doors. Codebook to cover both files and
  the link. `doors_involved` stays on events (event-level count) unless Peter wants strict no-derivables.
- Ask Hunter for a CSV (and RDS) export of officer_shot.

## Next

- Peter to send Hunter the reply (drafted in session). After the conference: build a download page for each dataset.

## Later the same day: done on our end (Hunter: "go ahead and take care of everything")

Plan: `plans/2026-11-10_derivative-datasets-trim.md`. All edits on the shared drive, through Hunter's scripts.

- **K-12** (`k12_door_security/`): `build_v2025.R` step 5 now drops the wide door slots from events and
  `school_level_group` from doors at write time, and renames the per-door `total_victims` to `door_total_victims`
  (Peter's call: it is door_killed + door_wound, not the event total). A `stopifnot` asserts `case_number` is the
  only shared column. The door fixes and the cross-file check still run on the internal wide copy. Events 54 x 69,
  doors 66 x 26. Values verified identical to the earlier files column for column; `check_vs_report.R` output is
  byte-identical (still only Figs 14, 19, 20 differ). Both checks updated for the dropped/renamed columns.
  Codebook text revised (no per-door block; files share only `case_number`; join for school level) and re-rendered;
  README file table, MD5s, and update procedure revised.
- **Officer shot** (`officer_shot/`): new `supporting_files/export_v2025.R` writes `officer_shot_data_v2025.csv`
  and `.rds` from the xlsx with a round-trip check (`date` as Date). Codebook names all three files and warns to
  read `officer_id` as text (30.10 vs 30.1); re-rendered on the Mac (`render_codebook.py` hard-codes the Windows
  Quarto path, so it was rendered directly); RESUME layout and steps updated, including a stale `v2024.xlsx` in step 5.
- Pre-change copies of every touched file are in the session scratchpad only (OneDrive version history is the
  durable backup).
- Hunter will move the SIA handover files to the archived grant folder himself. **If that includes
  `archive/coding_2000_2025/`, the build breaks**: `build_v2025.R` and both checks read from it.

## Next

- Download pages for both datasets, **before the conference** (Peter, 11-10: announced there as hosted on the site; target ~11-13).

## Evening: More Data page built (plan `plans/2026-11-10_datasets-page.md`)

Peter: one page, a citation per dataset, DOI later; and every dataset in the same format as the Active Attack
Data, so **CSV + codebook PDF only** (no RDS or xlsx on the site). Both codebooks now describe the CSV only.

- **Don't Name Them, officer shot.** The free text named attackers in 11 cells across 9 incidents (found by
  matching against `offender.name` in DATA_aa's raw workbook, then reading every capitalized word that is not an
  officer's name). Peter chose redaction at export: `export_v2025.R` carries a rule table (officer_id, column,
  from, to, expected count) that swaps in "the attacker", stops if any rule misses, and stops if a known name
  survives. The internal xlsx keeps the source text. Codebook states the policy. Officers and victims stay named
  (Rougeau, case 67, is the trooper). K-12: no attacker names (hits were school names, race values, gun makers).
- `0_set_up.R`: `update_derived_data()` copies the five files into `data/derived/` (committed for CI). The drive is
  found through `AA_RESEARCH_DRIVE` or the Mac OneDrive mount; skipped in CI and with `AA_SKIP_UPDATE=1`.
- `R/codebook.R`: `dataset_citation()`; `aa_citation()` now wraps it, with output identical to before (checked).
- `datasets.qmd` ("More Data" in the navbar, after Active Attacks): per dataset, figures computed from the files,
  download buttons, four reading notes, citation + BibTeX. Cross-links from the Download the Data tab and the
  Codebook page; Home changelog entry.
- CSS: `h3.cb-h3`; citation links wrap (`overflow-wrap: anywhere`); BibTeX blocks scroll inside their box
  (also fixes the Codebook page at phone width).
- Checks: full-site render before/after, visible text differs only by the new navbar item, the two link lines and
  the changelog; no horizontal scroll at 375 px in light or dark (headless `--screenshot` lays narrow windows out
  wider than asked, which looks like clipping; measure with Playwright instead); every download decodes to its
  source file.

## Next

- Push (Peter's approval). Then tell Hunter: the redaction rule table lives in `export_v2025.R`, so any edit to
  those notes in his pipeline must keep the rules matching (the export stops otherwise).

## Codebook covers and navbar (later still)

- Navbar: Home tab dropped (the logo links to `index.html`); five items now.
- Each dataset's downloads sit in a `.ds-download` panel beside the codebook's page-1 thumbnail, the Fact Sheet
  pattern. `update_derived_data()` makes `www/<codebook>_preview.png` with `pdftoppm` (40 dpi) whenever the PDF is
  newer than its thumbnail; the PNGs are committed for CI.
