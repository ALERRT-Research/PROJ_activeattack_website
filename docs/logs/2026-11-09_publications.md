# 2026-11-09: Publications page

Peter (11-09): list every article that used the Active Attack Data, and give the public a way to report their own
papers, presentations and projects so we can list them too.

## Built

- `data/publications.yml`: one entry per work (type, year, authors, title, venue, doi or url, a one-line `uses`,
  optional `by: others`). Edit this file to add a work; nothing else changes. Started from the ALERRT publications
  list on the shared drive (`published_articles/1_ALERRT_publications.docx`) and alerrtresearch.org; DOIs filled from
  Crossref where the list had none (Duron 2021 is in the International Journal of Disaster Risk Reduction, not JTAM
  as the list says).
- `R/publications.R`: `publications_load()` and `publications_html()`, grouped by type (articles, reports, books,
  chapters, other), newest first, reference line + link + muted "uses" line.
- `publications.qmd`: intro, key numbers, the list, "Tell us about your work" (a mailto button to Peter, cc Hunter,
  with the questions pre-filled in the body; plus the plain address), "Citing the data" with the suggested citation.
- Navbar: Home, Active Attacks, Publications, Remembrance, Contact. Home grid gains a Publications card (3 x 3).
- fbi.gov and leb.fbi.gov answer 403 to curl (bot wall) but the URLs are the FBI's stable active-shooter pages.

## Included (15)

Articles: vehicle attacks (2025), officers shot and killed (2022), definitional confusion (2022), high-casualty
events (2021), correlates of shot and killed (2020), training protocols since Columbine (2019), workplace events
(2017). Reports: SIA locked doors (2026), FBI/ALERRT annual reports (2019, 2018, 2016-17) and the 2014 study.
Book: Active Shooter Events and Response (2013). Chapter: ASHER overview (2021). Other: FBI LEB 2000-2012 (2014).

## Left out as uncertain, for Peter and Hunter to rule on

- Martaindale, Sandel & Duron (2023), door locks, JMVR: experimental lock testing; did it draw on the event data?
- Blair & Martaindale (2024), The Chain of Survival (book): uses the data for context?
- Martaindale & Tanksley (2025), public opinion and immediate entry: a survey experiment; event data only as framing?
- Martaindale & Blair (2017) Journal of School Safety; Martaindale (2015) RCMP Gazette: non-refereed, no links.
- Work by researchers outside ALERRT: none known yet; the mail-in button is how it arrives. Set `by: others` and the
  renderer can show a separate section when there is one (not yet written; one `if` in `publications_html()`).

## Alternatives considered for the form

A Microsoft Form or Google Form would collect entries without email, but needs an account owner and a periodic
check; a pre-filled mailto needs nothing and lands in Peter's inbox. Switch later if volume warrants.
