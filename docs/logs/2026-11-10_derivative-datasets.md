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

- Download pages for both datasets (post-conference).
