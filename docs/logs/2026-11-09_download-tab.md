# 2026-11-09: Download the Data tab; codebook findings

## Tab rebuilt (`1_visuals.qmd`, `dashboard.css`)

- Layout now matches the other tabs: the table card on the left (62%), notes on the right (38%). Download
  buttons (CSV, codebook DOCX) sit at the top of the table card instead of under three paragraphs of prose.
- Header gains a Years stat (2000-2025). Notes rewritten under `.aa-subhead` headings: one row per attack,
  attacker variables, inclusive counts, how attacks ended, versions, using the data (credit line, Contact link).
- Earlier versions linked for reproducibility (v2024 CSV + codebook, v2023 CSV + the unversioned codebook, which
  is the v2023 one by date); those files are added to the page's `resources:`. This gives the orphaned data files
  in `data/` a purpose; remove the links if Peter would rather not publish old versions.
- DT: `rownames = FALSE`, `class = "display nowrap"`, `scrollX`, 10 rows a page. **Quarto dashboards inject
  `bPaginate: false` and "Showing _TOTAL_ entries" through `DT.options`**, which is why the live table showed every
  row in a short scrolling card; the call now sets `bPaginate = TRUE` explicitly. The card holds two bodies
  (download row, widget) and Quarto sizes them as fill items, so `dashboard.css` forces the card and its bodies to
  `height: auto` (same trick as `.aa-head`). Table styled in ink/rule tokens; pagination in ink.
- Inline code in `.aa-notes` styled ink-on-surface (flatly renders it purple).
- Changelog entry on the Home page.

## Codebook findings (not changed)

- `aa_data_wide_codebook_2025.docx` is an officer wrapper: one paragraph with the ALERRT logo and an altChunk
  embedding the codebookr document, which itself holds 46 altChunks (one per variable). Word expands these;
  pandoc, Quick Look and most non-Word readers show only the logo. The variable tables are not reachable outside
  Word. Options: flatten by opening in Word and Save As (manual, every version), or build the codebook as a site
  page (and Typst PDF, like the fact sheet) from a variable-label table exported by DATA_aa. Recommendation: the
  page; the published rds carries no labels, so DATA_aa would need to export them. Peter to decide.
- `kill_guard_tot` label said "wounded"; fixed in DATA_aa `codebook_events.R` (commit 2f4793b, not pushed, takes
  effect at the next codebook build).
- Data quirks for Hunter: `weapon_pistol_tot`, `weapon_shotgun_tot`, `weapon_rifle_tot` are character columns
  (6 NA); `resolution` is character while the other categoricals are factors.

## Environment

- On this Mac the website's renv library holds 16 of 142 locked packages (R 4.5.1 vs lock 4.3.3), so
  `quarto render` fails with "no package called rmarkdown". Rendering with `RENV_CONFIG_AUTOLOADER_ENABLED=FALSE`
  uses the user library, which has everything. The 11-06 renders were on the other machine.
