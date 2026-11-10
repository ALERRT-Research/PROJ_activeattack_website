# Plan: one "More datasets" page for the K-12 door security and officer shot data

Status: COMPLETED (2026-11-10). Target: live by ~11-13 (both datasets will be announced at the ALERRT
conference, Nov 16-19, as hosted on the site).

Decided (Peter, 11-10): one page, a suggested citation for each dataset, DOI later.

## 1. Data into the repo (`0_set_up.R`, `data/derived/`)

- New `update_derived_data()`, using the existing `copy_ifelse_checksums()` pattern: copies the K-12 events and
  doors CSV/RDS and codebook PDF, and the officer shot CSV/RDS/xlsx and codebook PDF, into `data/derived/`, which
  is committed so CI can render (same reason `data/` is committed today).
- Where the drive is: the env var `AA_RESEARCH_DRIVE` if it is set, otherwise a search for the Mac OneDrive mount
  (`~/Library/CloudStorage/OneDrive-SharedLibraries-*/Martaindale*Research`). No hard-coded absolute path.
  Skipped in CI (`GITHUB_ACTIONS`) and when the drive isn't found (message only, like a missing feeder).

## 2. Citation helper (`R/codebook.R`)

- Turn `aa_citation()` into a general `dataset_citation(title, key, version, year, url)` and keep `aa_citation()`
  as a thin wrapper, so the existing Codebook, Publications and Download text does not change (checked by
  diffing the rendered HTML before and after).
- K-12: *K-12 Door Security Dataset* (Version v2025) [Data set], URL `datasets.html#k-12-door-security`, plus
  Hunter's README line: for the 2000-2025 findings, also cite the 2026 report.
- Officer shot: *Officers Shot in Active Shooter Incidents* (Version v2025) [Data set], URL
  `datasets.html#officers-shot`. Year = 2026 (posting date) for both. BibTeX for each, as on the Codebook page.

## 3. The page (`datasets.qmd`)

Built in the existing site style (`.aa-intro`, `.cb-facts` stats from `aa_stats_html()`, `.aa-dl` buttons,
`.aa-cite`), toc on, so each dataset is linkable.

- Intro: two datasets built from or alongside the Active Attack Data, with what each is for.
- **K-12 door security**: what it covers (54 K-12 attacks, 2000-2025, 66 doors); stats computed from the files
  (attacks, doors, years, version); downloads (events CSV, doors CSV, both RDS, codebook PDF); how the two files
  link (`case_number` only; join for school level); SIA funding and the 2026 report credited; citation + BibTeX.
- **Officers shot**: what it covers (156 officers in 75 incidents, 2001-2025, linked to the Active Attack Data
  by `aad_case_code`); stats from the file; downloads (CSV, RDS, xlsx, codebook PDF); read `officer_id` as
  text; citation + BibTeX.
- Every number on the page is computed from the files, none typed in.

## 4. Links

- Navbar: "More Data" between Active Attacks and Publications.
- Home: changelog entry, plus a line or card pointing to the page.
- Download the Data tab and Codebook page: one line each, "Related datasets: ...".

## 5. Checks

- **Don't Name Them**: scan every text column of both datasets for attacker names, matched against the attacker
  name fields in DATA_aa's raw data (if present) plus a manual read of the free-text notes. Any hit is reported to
  Peter and Hunter, not edited here.
- Local render (`RENV_CONFIG_AUTOLOADER_ENABLED=FALSE`, feeders fetched first), the whole site; the existing pages'
  HTML is unchanged apart from the new navbar item and the link lines.
- Light and dark, 375 px and 1400 px screenshots; every download link resolves to a file in `_site/`.
- `index.qmd` changelog; log + bob.md. Push only on Peter's approval.

## Assumed (Peter can override)

- Page and navbar names ("More datasets" / "More Data").
- Peter, 11-10: every dataset posts in the same format, CSV + codebook PDF only (no RDS or xlsx on the page).
