# Plan: fixes from Hunter's Claude review (2026-11-12)

Status: DRAFT. Source: `~/Downloads/website_feedback_full.md` (not copied into the repo).
Inline numbers in `1_visuals.qmd` are computed (`{r}` chunks), so most numeric errors are definition bugs, not typos.

## A. Mechanical (no decisions)

1. **Oxford commas**, site-wide in all `.qmd`, `R/*.R` strings, and `data/publications.yml`. List in feedback section 3; grep each page, read every hit, do not regex blindly (e.g. "news and agency reports, ..." already fine).
2. **Typos and grammar**, feedback section 2: casualities, colour/calibre, "appear to be more events", comma splice in Timing intro, "appears to be only a modest trend", lowercase "active attacks", "alone" for him/herself, Jan 8 2011 comma, "store," comma, institutions of higher education, "can be seen", "These spikes", Fort Hood form (use "Fort Hood" for 2009 in both places), Delaware sentence, "tends to cluster", animation sentence, "has risen over the period", "More Data" capitalization (title vs navbar), Publications intro (2013 CRC book precedes FBI study), nested parentheses in relationship paragraph, employees before students.
3. **Publications**: add the six entries (book + FBI 2020-2024 reports) to `data/publications.yml`; leave out the 2014-2015 report. Expect counts 5 -> 10 reports, 1 -> 2 books, 15 -> 21 works (check the page's own count text). Book `uses:` line is draft; Peter/Hunter confirm.
4. **Flat bar color** on Attackers (and any other rank-shaded bars): graphics repo, one color per chart, light and dark twins. Check `bw`/palette code in `plots_cartesian.R`; rerun `AA_MODE=dark` too; the website copies on render.

## B. Number fixes (mechanical once the definition is chosen)

5. **Five-year averages**: `get_mean(..., (years_max-5):years_max)` spans six years; second window is 2006:2010 (feedback says 2005-2009 gives 13.2). Fix to a true five-year window each. Decide: last five = 2021-2025 (45.8 -> 46) or 2020-2024 (fact sheet window, 46.4).
6. **Hour of day**: "the majority" -> "half of all attacks" (161 + 156 = 317/634 = 50.0%).
7. **Weapon percentages**: denominator is all attacks (54.7/29.2/8.4); fact sheet uses firearm attacks (58.7/31.3/9.0). Pick one, label it; "handguns" vs "Pistol" pick one; fix "of the time" grammar.
8. **Rifles "all attacks > 20 deaths"**: delete or reword (Virginia Tech was a pistol).
9. **66% tile**: `round(norel_pct)` on a value already rounded to 65.5; round from the raw 65.46 -> 65%. Check `get_pct`.
10. **Offender sex 96.2%**: find where `male_pct` comes from; data give 97.0% (first-listed) or 96.5% (all attackers).
11. **Fact sheet Victims table blank % column**: drop the column or show share of total victims.

## C. Needs a decision from Peter (and maybe Hunter)

- **Attacker counting basis** (race, sex, weapon, text vs chart vs fact sheet): every attacker or first-listed attacker? Recommend one basis everywhere and a one-line statement of which. Also split "all other groups" from "unknown" (20.5% vs 3.2%).
- **Race framing sentence**: recommend dropping "roughly mirrored the general population".
- **Relationship label**: Locations text says relationship to the place; fact sheet (web and PDF, `R/fact_sheet_stats.R` lines ~99-103) and codebook say "Relationship to victims". Is the variable relationship to the location or to victims? Hunter/DATA_aa owns the codebook label (`codebook_events.R`), so a fix there goes through him.
- **Remembrance counts** (2006, 2010, 2016-2019, 2020, 2021, 2024, plus 2000/2007/2011/2015 more names than deaths): reconcile names list vs `kill_tot`. This is the open "victims list vs events deaths" item already pending with Hunter. Interim: relabel headings "29 of 32 named" (and wording for years with more names than deaths).
- **SIA date range**: Publications says 2000 to 2025, More Data says 2001-2025; check `k12_door_security` (first attack year) and fix whichever is wrong.
- **"an individual or individuals is actively killing"**: official ALERRT wording? If so leave it.
- **Blair et al. (2025) vehicle note**: confirm data window of that paper.

## Order and checks

1. Text and comma edits (A1-A3, B6, B8), then render, then diff visible text against the pre-edit render (same method as the 11-10 More Data check).
2. Number definitions (B5, B7, B9, B10) after Section C answers; recheck every changed figure against `aa_data_wide_nogeo_2025.csv`.
3. Graphics repo for A4, dark twins included; render again.
4. Fact sheet PDF rebuild if the fact sheet changed (`Rscript R/fact_sheet_pdf.R`).
5. Log to `docs/logs/`, update bob.md; fold the Hunter items into the single end-of-session mail. Push only on Peter's explicit approval (deadline ~11-13).
