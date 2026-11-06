# 2026-11-06: Fact sheet stats script; relationship/location data fix

Step 1 of `plans/2026-11-06_fact-sheet-retool.md`.

## Done

- `R/fact_sheet_stats.R`: every fact-sheet number computed from the wide data, plus 2024, 2025, change, and
  the 2020-24 per-year average. `R/check_fact_sheet_v2025.R` reconciles against the hand-typed v2025 sheet:
  **43/43 reproduce** after the fix below (39/43 before).
- Reconciliation exposed two DATA_aa issues, fixed with Peter's approval:
  - `code_events.R` relationship recode matched `"former employee/co-worker"`, but the raw sheet spells it
    `"former employee/coworker"`: 33 events fell into "other". Released CSV, codebook and relationship figure
    undercounted coworkers (66 → 99; other 40 → 7). The published fact sheet was already right (built from the
    raw xlsx).
  - Church (22) and military base (7) kept as their own `location_primary` levels (same reasoning as medical
    facility, 09-14).
- Pipeline rerun on Peter's Mac: only `location_primary` and `relationship` changed (geometry diff 7e-9 deg,
  float noise). Codebook regenerated.
- Graphics: `plots_cartesian.R` folds church/military base back into "Other" so location figures are unchanged.
  Only `univar_rel.png` and `bivar_loctype_rel.png` kept from the rerun; every other figure differed only by
  Mac-vs-Windows rendering and was reverted.
- Website: `1_visuals.qmd` "Other" location text now counts Other + Church + Military base (would otherwise
  have dropped 91 → 62); missing `%` added in the coworker sentence; `index.qmd` changelog entry. Local render
  of `1_visuals.qmd` checked.

## Still to do

- Tell Hunter (pipeline is his): the recode fix and new location levels; his next Windows render of graphics
  will re-byte the reverted figures, which is harmless.
- Plan steps 2-5 (web tab, styling via frontend-design, Typst PDF, wire-up).
- Nothing pushed.
