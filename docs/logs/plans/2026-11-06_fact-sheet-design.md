# Fact sheet design direction (step 3 pilot for the site-wide look)

**Status:** APPROVED 2026-11-06 (maroon accent; pilot scoped to the Fact Sheet tab); built, see "As built" at the end. Parent plan: `2026-11-06_fact-sheet-retool.md`.

## Brief, as understood

- **Subject:** ALERRT's public reference numbers on active attacks in the US, 2000 to the latest year.
- **Audience:** police trainers and command staff, journalists, researchers, policy staff; the fact sheet is
  the page they quote, screenshot and print. Conference crowd in November.
- **Primary job:** answer "how many, what kind, and how is this year compared with last" in under a minute,
  with numbers that look citable.
- **Tone:** sober and institutional. People died in every row of this data; nothing alarmist (no red), nothing
  playful, nothing that looks like a marketing dashboard. Attackers are never named.

## Tokens

| Name | Light | Dark | Use |
|------|-------|------|-----|
| Ink | `#1F2A36` | `#E4E8EC` | text, rules under headers; harmonizes with the existing navbar slate `#2C3E50` |
| Paper | `#FFFFFF` | `#141A21` | page |
| Surface | `#F4F6F8` | `#1B232C` | cards, group rows (cool grey, not cream) |
| Rule | `#D3D8DE` | `#2E3843` | hairlines between rows |
| Muted | `#5B6672` | `#9AA5B1` | percentages, prior-year and average figures |
| Maroon | `#501214` | `#D29AA0` | the latest year only (Texas State maroon; ALERRT's logo rule) |

One accent, used for one meaning: **anything maroon is the latest year.** No red/green anywhere; change is a
signed number plus a small neutral triangle in Muted.

**Type:** Public Sans (Google Fonts), one family throughout. It is the US Web Design System's typeface, built for
public-sector data, with real tabular figures, and it is not what this kind of site usually reaches for.
Scale on a 1.25 ratio from 16px body: 16 / 20 / 25 / 31 / 39; headline figures at 49px weight 300. Numbers are
`font-variant-numeric: tabular-nums` and right-aligned everywhere. Sentence case labels; no all-caps eyebrows,
no monospace labels.

## The one memorable thing: the comparison rule

Each headline box stops being "big number + small grey caption" and carries a small horizontal scale that
shows three marks on the same axis: the prior year (thin Muted tick), the latest year (solid Maroon bar), and
the five-year average (dashed tick). A reader sees at a glance that 2025 is above 2024 but below the recent
average, which is the story the plan says the tiles must tell. Built from plain HTML spans with widths computed
in R; no JavaScript, no new packages; marks differ by shape as well as colour, so it reads in greyscale and print.

```
 Active attacks, 2025
 37                                        (49px, weight 300, maroon)
 |-------------|=========|- - - -:         0 ............ max
               2024 29   2025 37   2020-24 avg 46.4
```

Everything else stays quiet.

## Tables

```
 Weapons
 ─────────────────────────────────────────────────────────────────────
 Category              2000–2025      2024  ┃2025┃  Change  2020–24 avg
 ─────────────────────────────────────────────────────────────────────
 Primary weapon                                                       (Surface row, semibold, sentence case)
 Firearm            591  93.2%          24  ┃ 34 ┃     ▲ 10       44.6
 Blade               30   4.7%           4  ┃  2 ┃     ▼  2        1.0
```

- No zebra stripes; hairline Rule between rows; Ink rule under the header.
- **Latest-year column carries a faint maroon band** (maroon at ~6% opacity) top to bottom, with the header in
  Maroon, so the eye can read 2025 straight down every table. That links the tables to the headline boxes.
- Percentages sit in their own Muted sub-column instead of in parentheses, so counts align.
- Resolution subtotals ("Before police arrived") get a top rule and semibold, so the two halves read as blocks.
- Phones: Category plus 2025 and Change stay visible; the table scrolls horizontally inside its card with the
  Category column pinned, rather than squeezing six columns into 360px.

## Cards and page

- Dashboard cards keep their grid but lose the grey header bars: title as a 20px semibold heading on the card
  itself, 1px Rule border, 6px radius, no shadow.
- The intro card becomes a single line with the download button beside it, not a full-width box.
- "Reading these numbers" stays last, set at 15px in Muted, max 72 characters per line.
- Light and dark from the same tokens (Quarto `theme: light/dark` pair over flatly/darkly, which adds the toggle).
  The pilot scopes the new look to the Fact Sheet tab; the rest of the site keeps today's look until step 3b.

## Review against the generic defaults

- First draft kept the four grey stat boxes with a bigger number and a coloured top border: that is the stock
  "big number, small label" kit. Replaced with the comparison rule, which carries information the boxes did not.
- First draft had zebra-striped tables with a coloured header row (the SaaS default, and today's flatly look).
  Replaced with hairlines plus the single latest-year band, which encodes meaning instead of decorating.
- Considered a serif display face for an "official report" feel; dropped as the cream-and-serif cliché and
  because one well-chosen sans with tabular figures serves dense numbers better.
- The tiles' current "2024: 29 · 2020–2024 avg." strings use middle-dot meta; the comparison rule's own labels
  replace them.
- Maroon is the client's institution colour, not a borrowed accent; it is used for exactly one meaning.

## The PDF (step 4) inherits this

Same tokens and Public Sans in Typst; the comparison rules become a four-up row on page 1; the maroon band
carries over to the tables.

## As built (2026-11-06)

Peter's steer on approval: keep it near Carpe Audience simple, easy to read, hard to misread. Changes from the
draft above, all in that direction:

- **Comparison rule → three short bars from zero** (2024 grey fill, 2025 maroon fill, five-year average as an
  outline), each with its value printed. Ticks on one shared line made the reader decode positions.
- **"Ended before police arrived" shows the share** (70% in 2025, "26 of 37 attacks" beneath; bars in %), since
  the count rises with the number of attacks.
- **No change triangles.** The column header is "vs. 2024" and the cell is a signed number.
- **Columns drop by card width (container queries), not window width:** under 600px the % and average columns
  go, under 430px the prior-year column goes; cards stack one per row below 700px. Measured: no table overflows
  from 375px to 1400px; at 320px tables scroll sideways.
- Quarto adds Bootstrap `table-striped small` to every table; the fact-sheet tables opt out with
  `data-quarto-disable-processing="true"`.
- Dark tokens are defined under `.quarto-dark #fact-sheet`, unused until the light/dark toggle is switched on.
- All styles live in `dashboard.css`, scoped to `#fact-sheet`; Public Sans loads from Google Fonts.

**Revised same day after Peter's review:** the three bars now share one grid, so they start at a common zero
line (a vertical rule) with year labels right-aligned against it; previously each row sized its own label and
the average bar started further right, reading as floating bars. Maroon brightened from the logo's `#501214`
to `#9E1B32` (the dark logo colour did not pull the eye), 2025 table cells take the maroon, and the 2025 column
header is a solid maroon cell with white text.
