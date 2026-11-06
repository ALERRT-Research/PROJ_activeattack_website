# Page format: dashboard tabs and Home

**Status:** APPROVED 2026-11-06 (Peter chose all four items). Follows `2026-11-06_site-wide-look.md`.

## 1. Tab headers (every dashboard tab except Fact Sheet, which has its own)

- A header card at the top of each tab: the tab's title (h2), a one-line lead, and two or three key numbers
  computed from the data (no hand-typed figures). A 3px top rule in the tab's figure colour ties the page to its
  charts (Timing ochre, Attackers steel blue, Locations sea green, Casualties dusty violet; USA and Download in ink).
- Helper: `R/page_helpers.R` `tab_header(title, lead, stats)` returns HTML; styles in `dashboard.css` (`.aa-head`).

## 2. Chart first

- Swap the two columns: the chart tabset first and wide (about 62%), the explanatory text second (about 38%).
- The text card is renamed "What the figures show"; each chart's paragraph gets a small heading that matches its
  chart tab (`.aa-subhead`, in the tab colour).

## 3. Downloads and labels

- Images no longer carry the download button in their caption. Under each chart: one row of buttons
  ("Download PNG", and "Download interactive (HTML)" where there is one).
- Card tab names in sentence case and consistent wording.
- Remove fixed row heights that leave dead space; check every tab at 1400 and 700 px.

## 4. Home front section

- Before History: a short opening with the purpose in one sentence, four headline numbers (attacks, killed,
  wounded, years covered) and links into each dashboard tab and the Fact Sheet. Computed from `data/`.
- History, Definitions, Website Guide, The ALERRT Center, Updates stay below unchanged.

## Checks

Full local render; screenshots of every tab and Home at 1400 and 700 px; no horizontal overflow; numbers in
headers match the fact sheet (634 attacks, 1,477 killed, 2,810 wounded).
