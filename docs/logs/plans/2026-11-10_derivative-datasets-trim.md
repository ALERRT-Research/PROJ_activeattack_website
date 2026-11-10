# Plan: trim the K-12 door security files; CSV for officer_shot

Status: COMPLETED (2026-11-10)

Hunter (11-10): "go ahead and take care of everything on our end." Scope is the data side only. The download
pages stay post-conference.

Both folders are Hunter's source of truth on the shared research drive (`data/raw_data/`). Work goes through
his build scripts, not by hand-editing outputs, and follows his README's update procedure.

## K-12 door security (`k12_door_security/`)

Decision (Peter, 11-10): two files linked by `case_number` only.

1. `supporting_files/build_v2025.R`, step 5 (Write): just before writing, drop the door slot columns
   (`^door_.*_[1-5]$`) from the events file and `school_level_group` from the doors file. The door fixes and the
   events-vs-doors cross-check upstream stay as they are; they still run on the internal wide copy, so nothing
   is lost.
2. `check_vs_source.R`: the WIDE comparison will list the door columns as "only in source". That's expected;
   add a note. Door cells are still compared in the LONG check.
3. `check_vs_report.R`: wherever the doors table needs `school_level_group`, join it from the events file on
   `case_number`.
4. Codebook (`supporting_files/codebook/`): remove the "Per-door block (slots 1-5)" section; reword the
   descriptions that mention both files ("Events file 1 / 0 / unknown; doors file ...", "matches the wide door
   slot", `total_victims`); say the files link on `case_number`; drop any mention of the extra SIA-handover CSVs.
   Re-render and copy the PDF up.
5. Run the build and both checks; confirm the only differences are the dropped columns. Update the README:
   file table (columns, MD5s), the "door information stored in both files" paragraph, and update step 1.

## Officer shot (`officer_shot/`)

6. Export `officer_shot_data_v2025.xlsx` (one sheet, 156 x 42) as CSV + RDS beside it, from the pipeline,
   and add the files to its README/RESUME.

## Verify

- Build runs clean, and the stops pass; events about 65 columns, doors 26; `case_number` is the only shared
  column.
- Codebook PDF renders; column counts in the text match the files.
- officer_shot CSV round-trips (same dim and values as the xlsx).

## Record

- Log entry in `docs/logs/2026-11-10_derivative-datasets.md`; bob.md backlog line updated.
