# 2026-11-12: 2013 zip codes shifted one row (Hunter's report)

**Finding.** In the source spreadsheet (`aa_data_{2023,2024,2025}.xlsx`), cases 168-188 (21 attacks, 2013) carry the zip of the neighbouring row; case 168 holds case 188's. City and state are right, so only `zip_code` and the zip-derived `event_lat/lon` were wrong. Counts by year unaffected. Every version of the file has it. Hunter's repo; the spreadsheet itself still needs correcting at source or the next refresh restores the shift.

**Fix (DATA_aa `code/code_events.R`, "zip code validation").** Flag any attack whose zip is in a different state AND city than listed (22 flagged after the Pentagon exemption: the 21, plus 403). Repair order: orphaned zip from the flagged set matching the city (edit distance <= 2), else orphaned zip in the state (nearest case code breaks ties), else most populous zip of the listed city (approximate). Unresolved cases warn, never guess. Result: 22 flagged, 22 repaired, 0 unresolved; all 21 of 2013 equal the row-shift truth exactly.
- Case 185 state "LA" corrected to "CA" in the raw-data step (beside the case-53 fix).
- Case 115 (Pentagon, Arlington VA) keeps zip 20301 (Peter, 11-12: special case). `zip_keep` in the validation block exempts it; its dot plots in DC, as before.
- Case 185 (LAX) set to 90045, LAX's own zip (Peter, 11-12), applied after the repair step so 87101 stays available to case 184; the source's 90017 is downtown LA.
- Case 403 Rockford IL had a Wisconsin zip; now 61107 (approximate, city lookup).
- 77410 (Cypress TX) and 87101 (Albuquerque NM) are PO-box zips with no coordinates; appended to `input/events/2023/zip_coords_completed.csv` with city-area points (4/9/2013, 10/26/2013).
- Case 256 Orem has state "OR" (should be UT); zip is right, left alone.

**Rebuilt.** DATA_aa outputs; graphics `plots_geospatial.R` light and dark (rolling_map.gif, bicol map html, frames); website full `quarto render` (data/ copies and downloadable CSV refreshed, 22 zip rows changed). Codebook PDF unaffected.

**State.** DATA_aa, graphics and website changes all uncommitted and unpushed. DATA_aa is Hunter's repo (he pushes to main): commit and pushing need Peter's go-ahead.

**To tell Hunter.** The shift in the xlsx (cases 168-188), case 185 state "LA", case 256 state "OR", case 185 zip (LAX 90045), case 403 Rockford zip, and that the pipeline now validates zips against listed city/state.
