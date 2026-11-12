# 2026-11-12: Hunter's Claude review, mechanical fixes

Source: `~/Downloads/website_feedback_full.md`. Plan: `plans/2026-11-12_hunter-feedback-fixes.md`.

## Done (committed, not pushed)

- Oxford commas across `index`, `1_visuals`, `datasets`, `codebook`, contact, `page_helpers.R`, `fact_sheet_html.R`, `codebook_pdf.R`, `codebook.R`, `publications.yml`. Every site hit was read; existing correct lists untouched.
- Grammar and typos (feedback section 2): casualties, color, appear/appears agreement, comma splice, alone, commas after 2011 and "store", institutions, "seen", "spikes", Fort Hood (2009) both places, "The only state with no recorded attacks is Delaware" (reads `states_miss`), "tends to cluster", animation sentence, "has risen over the period", relationship paragraph (employees first, no nested parentheses), "More Data" capitalization, Publications intro (2013 book).
- Publications: Chain of Survival book + FBI reports 2020-2024 added; 2014-2015 report left out. Page now shows 21 works, 10 reports, 2 books.
- Flat bar color: `rank_shades()` in graphics `0_packages.R` now returns one flat tab color (race, weapon, location bars and ridges); light and dark regenerated; copied to `www/` on render. `rel_pal` (relationship identity colors) unchanged.
- Codebook PDF rebuilt for the two comma fixes.

## Left for decisions or Hunter

Attacker counting basis, race framing, 66% tile (65.46), five-year averages, hour-of-day "majority", weapon denominator, rifles/20-deaths sentence, sex 96.2%, Victims table % column, relationship label, Remembrance counts, SIA date range, definition wording, Blair vehicle note. "calibre" lives in DATA_aa (`codebook_events.R`, labels CSV): Hunter's repo.
