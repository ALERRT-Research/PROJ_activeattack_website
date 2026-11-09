# 2026-11-09: Contact page in the site look

- Pulled the graphics repo (18 of Peter's own 11-06 commits; this clone was behind, nothing from Hunter).
- `3_contact.qmd` rebuilt from the bare two-row table: intro (heading + lead, same rules as Remembrance), one card
  per person (name, role, Texas State email; the alerrt.org addresses were replaced at Peter's request, Hunter's taken from the vehicle-attacks manuscript title page), "What to write about" in three columns (the data, a
  correction, using the data), and a "More from ALERRT" paragraph (ALERRTResearch.org, ALERRT.org, GitHub).
  No R, so the page renders without the sibling repos.
- CSS appended to `aa-theme.css` (`.aa-intro`, `.aa-people`/`.aa-person`, `.aa-reasons`). The reasons grid is one
  column below 760px and three above; `auto-fit` left the third item orphaned at mid widths.
- Checked with headless Chrome at 1400, 900 and 640 px. At 400 px headless Chrome clips the right edge on every
  page of the site (it does not emulate a phone viewport), so that is not a page defect; earlier phone checks
  were done another way.
- Wording that is new, not carried over: the "Using the data" item asks users to credit the ALERRT Center's
  Active Attack Data and link to the site. Peter to confirm or change.
- Committed (572f1e7), not pushed.
