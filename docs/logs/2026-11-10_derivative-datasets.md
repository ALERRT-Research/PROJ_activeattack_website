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
