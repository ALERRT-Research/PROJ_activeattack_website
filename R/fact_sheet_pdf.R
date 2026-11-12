#==============================================================================
# fact_sheet_pdf.R
#
# Builds the downloadable fact sheet PDF (data/aa_fact_sheet_<version>.pdf)
# from the same numbers as the Fact Sheet tab (R/fact_sheet_stats.R), in the
# same design (docs/logs/plans/2026-11-06_fact-sheet-design.md).
#
# R writes Typst markup to fact_sheet/aa_fact_sheet.typ, then compiles it with
# the Typst bundled in Quarto. No new R packages. Run locally once a year after
# the data update; the PDF is committed (the CI site build does not run this).
#
#   Rscript R/fact_sheet_pdf.R
#
# Unlike the web tables, the PDF keeps the prior-year column: it is the full
# printed reference (Peter, 2026-11-06).
#
# Fonts: static Public Sans in fact_sheet/fonts (SIL Open Font License, see
# OFL.txt there). Typst 0.11 cannot use the variable font's weights.
#==============================================================================

suppressMessages({
  library(tidyverse)
  library(glue)
})

source("R/fact_sheet_stats.R")

version  <- 2025
aa_data  <- readRDS(glue("data/aa_data_wide_nogeo_{version}.rds"))
fs       <- fact_sheet_stats(aa_data)
yrs      <- attr(fs, "years")
out_typ  <- "fact_sheet/aa_fact_sheet.typ"
out_pdf  <- glue("data/aa_fact_sheet_{version}.pdf")

#--helpers---------------------------------------------------------------------

# escape text for Typst content blocks
# (perl = TRUE: in TRE the \] inside the class ends it early and nothing is escaped)
ty <- function(x) gsub("([\\\\#$*_@<>\\[\\]`~=])", "\\\\\\1", x, perl = TRUE)

fmt_n <- function(x, kind = "count") {
  ifelse(is.na(x), "", scales::comma(x, accuracy = 1))
}

fmt_change <- function(x) {
  case_when(is.na(x) ~ "",
            x > 0    ~ paste0("+", scales::comma(x, accuracy = 1)),
            x < 0    ~ paste0("−", scales::comma(abs(x), accuracy = 1)),
            TRUE     ~ "0")
}

g <- function(item, col) fs[[col]][fs$item == item][1]

win_lab <- glue("{yrs$window[1]}–{substr(yrs$window[2], 3, 4)} avg.")

#--headline boxes--------------------------------------------------------------

# one box = four cells (title, figure, note, bars); the boxes share one grid so
# their rows line up even when a title wraps
tile <- function(title, big, note, vals, val_text) {
  w <- 100 * vals / max(vals, na.rm = TRUE)
  c(glue("text(weight: \"semibold\", size: 8.5pt)[{ty(title)}]"),
    glue("text(size: 26pt, weight: \"light\", fill: maroon)[{big}]"),
    glue("text(size: 8pt, fill: muted)[{note}]"),
    glue('bars(({sprintf("%.1f", w[1])}%, {sprintf("%.1f", w[2])}%, {sprintf("%.1f", w[3])}%),
         ([{val_text[1]}], [{val_text[2]}], [{val_text[3]}]))'))
}

count_tile <- function(title, item) {
  v <- c(g(item, "n_prev"), g(item, "n_curr"), g(item, "avg_window"))
  tile(title, scales::comma(v[2]), "", v,
       c(scales::comma(v[1]), scales::comma(v[2]), scales::number(v[3], accuracy = 0.1)))
}

pre   <- c(g("Before police arrived", "n_prev"), g("Before police arrived", "n_curr"),
           g("Before police arrived", "avg_window"))
tot   <- c(g("Active attacks", "n_prev"), g("Active attacks", "n_curr"),
           g("Active attacks", "avg_window"))
share <- 100 * pre / tot
pct   <- paste0(scales::number(share, accuracy = 1), "\\%")

tiles <- cbind(
  count_tile(glue("Active attacks in {yrs$curr}"), "Active attacks"),
  count_tile(glue("Killed in {yrs$curr}"),         "Killed"),
  count_tile(glue("Wounded in {yrs$curr}"),        "Wounded"),
  tile("Ended before police arrived", pct[2],
       glue("{pre[2]} of {tot[2]} attacks in {yrs$curr}"), share, pct)
)
# boxes 2 x 2 beside the map; row-major within each pair (titles, figures, notes, bars)
tiles <- c(as.vector(t(tiles[, 1:2])), as.vector(t(tiles[, 3:4])))

map_title <- glue("Where the {tot[2]} attacks in {yrs$curr} happened")

#--section tables--------------------------------------------------------------

section_table <- function(section_name, title) {
  d <- filter(fs, section == section_name)
  rows <- character()
  last_group <- ""
  for (i in seq_len(nrow(d))) {
    r <- d[i, ]
    subtotal <- !is.na(r$group) && r$item == r$group
    if (!is.na(r$group) && r$group != last_group && !subtotal) {
      rows <- c(rows, glue('group-row[{ty(r$group)}],'))
    }
    if (!is.na(r$group)) last_group <- r$group
    pct <- if (r$kind == "count") scales::number(r$pct_all, accuracy = 0.1) else ""
    avg <- if (r$kind == "median") fmt_n(r$avg_window)
           else scales::number(r$avg_window, accuracy = 0.1, big.mark = ",")
    cells <- paste0("[", c(ty(r$item), fmt_n(r$n_all), pct, fmt_n(r$n_prev), fmt_n(r$n_curr),
                           fmt_change(r$change), avg), "]", collapse = ", ")
    rows <- c(rows, if (subtotal) glue("table.hline(stroke: 0.75pt + ink), ..subtotal(({cells})),")
                    else paste0(cells, ","))
  }
  glue('#fs-table([{title}], (\n  {paste(rows, collapse = "\n  ")}\n))')
}

#--page text---------------------------------------------------------------------

total  <- scales::comma(g("Active attacks", "n_all"))

intro <- glue(
  "Every active attack identified in the United States from {yrs$first} through {yrs$curr}: ",
  "the events identified by the FBI plus those identified by ALERRT for the same period ",
  "({total} attacks). The list is rolling; as attacks happen or are found, the numbers adjust. ",
  "Each box and table compares {yrs$curr} with {yrs$prev} and with the average year from ",
  "{yrs$window[1]} to {yrs$window[2]}.")

notes <- glue(
  "*Columns.* The {yrs$first}–{yrs$curr} column covers every attack in the data, with its share ",
  "of the total (firearm types are a share of firearm attacks). The {yrs$prev} and {yrs$curr} columns ",
  "are counts, and _vs. {yrs$prev}_ is the change from the year before. Single years hold few attacks, ",
  "so a change of a few events is within normal year-to-year variation; the five-year average gives ",
  "the longer view.\n\n",
  "*Definitions.* _One weapon_ includes vehicle attacks and attacks with a firearm of unknown type. ",
  "Race counts every attacker (unknown included), so its rows total the number of attackers, not attacks. _Shot by civilian_ includes off-duty officers and ",
  "security guards. _Fled the scene_ includes a small number of attackers who fled after police ",
  "arrived. Victim counts follow ALERRT's definitions, which are stricter than the FBI's. ",
  "Year-by-year figures always come from the current version of the data, so attacks identified ",
  "later are counted in the year they happened.")

#--template----------------------------------------------------------------------

typ <- glue(.open = "<<", .close = ">>", '
// Generated by R/fact_sheet_pdf.R. Do not edit by hand; edit the R script.

#let ink     = rgb("#1f2a36")
#let muted   = rgb("#5b6672")
#let rule    = rgb("#d3d8de")
#let surface = rgb("#f4f6f8")
#let prevc   = rgb("#9aa5b1")
#let maroon  = rgb("#9e1b32")
#let band    = rgb(158, 27, 50, 20)

#set document(title: "Active attacks in the United States, <<yrs$first>>–<<yrs$curr>>: fact sheet",
              author: "ALERRT Center, Texas State University")
#set page(paper: "us-letter", margin: (x: 0.6in, top: 0.5in, bottom: 0.6in),
  footer: context [
    #set text(size: 7.5pt, fill: muted)
    activeattackdata.org #h(1fr) ALERRT Center, Texas State University #h(1fr)
    Page #counter(page).display() of #counter(page).final().first()
  ])
// tabular figures only where numbers stack (tables, bars); prose keeps proportional
#set text(font: "Public Sans", size: 9pt, fill: ink, lang: "en")
#set par(leading: 0.55em)

// three bars from a shared zero line: prior year, latest year, window average
#let bars(widths, vals) = { set text(number-width: "tabular"); grid(
  columns: (auto, 1fr, auto), column-gutter: 4pt, row-gutter: 0pt,
  inset: (y: 1.6pt), align: (right + horizon, left + horizon, right + horizon),
  stroke: (x, y) => if x == 1 { (left: 0.75pt + ink) },
  text(size: 7.5pt, fill: muted)[<<yrs$prev>>],
  box(width: widths.at(0), height: 6pt, fill: prevc),
  text(size: 7.5pt, vals.at(0)),
  text(size: 7.5pt, fill: maroon, weight: "semibold")[<<yrs$curr>>],
  box(width: widths.at(1), height: 6pt, fill: maroon),
  text(size: 7.5pt, fill: maroon, weight: "semibold", vals.at(1)),
  text(size: 7.5pt, fill: muted)[<<win_lab>>],
  box(width: widths.at(2), height: 6pt, stroke: 0.75pt + muted),
  text(size: 7.5pt, vals.at(2)),
) }

#let group-row(label) = table.cell(colspan: 7, fill: surface, text(weight: "semibold", label))
#let subtotal(cells) = cells.map(c => text(weight: "semibold", c))

// one section: 2024 and 2025 both shown; 2025 carries the maroon band
#let fs-table(title, body) = block(breakable: false, width: 100%)[
  #set text(size: 8.5pt, number-width: "tabular")
  #show table.cell.where(x: 4): set text(fill: maroon, weight: "semibold")
  #text(size: 12pt, weight: "semibold", title)
  #v(-6pt)
  #table(
    columns: (1fr, 62pt, 34pt, 38pt, 38pt, 46pt, 76pt),
    align: (x, y) => if x == 0 { left + bottom } else { right + bottom },
    inset: (x: 4pt, y: 2.25pt),
    stroke: (x, y) => (bottom: if y == 0 { 1pt + ink } else { 0.4pt + rule }),
    fill: (x, y) => if x == 4 { if y == 0 { maroon } else { band } },
    table.header(
      text(weight: "semibold")[Category],
      text(weight: "semibold")[<<yrs$first>>–<<yrs$curr>>],
      text(weight: "semibold", fill: muted)[%],
      text(weight: "semibold")[<<yrs$prev>>],
      text(weight: "semibold", fill: white)[<<yrs$curr>>],
      text(weight: "semibold")[vs. <<yrs$prev>>],
      text(weight: "semibold")[<<win_lab>>],
    ),
    ..body,
  )
]

// ---- page 1 ------------------------------------------------------------------

// header: the logo runs the full height of the text block beside it. The text
// width depends on the logo width, so measure and settle in a few passes.
// fact_sheet/alerrt_logo_trimmed.png is www/alerrt_logo.png with its margins trimmed.
#let head-text(w) = block(width: w)[
  #text(size: 18pt, weight: "semibold")[Active attacks in the United States, <<yrs$first>>–<<yrs$curr>>]
  #v(-6pt)
  #text(size: 9.5pt, fill: muted)[Fact sheet from the Active Attack Data, ALERRT Center, Texas State University]
  #v(2pt)
  #par(justify: false)[<<ty(intro)>>]
]
#layout(size => {
  let gap = 14pt
  let aspect = 516 / 701
  let h = 1.2in
  for _ in range(4) { h = measure(head-text(size.width - h * aspect - gap)).height }
  grid(columns: (size.width - h * aspect - gap, h * aspect), column-gutter: gap,
    head-text(size.width - h * aspect - gap),
    image("alerrt_logo_trimmed.png", height: h))
})
#v(8pt)

#grid(columns: (1.1fr, 1fr), column-gutter: 18pt,
  grid(columns: (1fr,) * 2, column-gutter: 14pt,
    row-gutter: (8pt, 3pt, 5pt, 12pt, 8pt, 3pt, 5pt),
    stroke: (x, y) => if calc.rem(y, 4) == 0 { (top: 1.5pt + ink) },
    inset: (x, y) => if calc.rem(y, 4) == 0 { (top: 5pt) } else { 0pt },
    align: (x, y) => if calc.rem(y, 4) == 0 { left + top } else { left + bottom },
    <<paste(tiles, collapse = ",\n    ")>>
  ),
  // latest-year map: PROJ_activeattack_graphics/code/plots_latest_year_map.R
  block(width: 100%, stroke: (top: 1.5pt + ink), inset: (top: 5pt))[
    #text(weight: "semibold", size: 8.5pt)[<<map_title>>]
    #v(2pt)
    #image("/www/map_latest_year.svg", width: 100%)
    #v(-4pt)
    #text(size: 8pt, fill: muted)[One dot per attack; attacks in the same place overlap.]
  ],
)
#v(6pt)

<<section_table("Weapons", "Weapons")>>
#v(8pt)
<<section_table("Attackers", "Attackers")>>

#pagebreak()

// ---- page 2 ------------------------------------------------------------------

<<section_table("Locations", "Locations")>>
#v(8pt)
<<section_table("Resolution", "How attacks ended")>>
#v(8pt)
<<section_table("Victims", "Victims")>>
#v(10pt)

#block(stroke: (top: 1.5pt + ink), inset: (top: 6pt), width: 100%)[
  #text(size: 12pt, weight: "semibold")[Reading these numbers]
  #set text(size: 8.5pt)
  #set par(justify: false)

  <<notes>>

  #text(fill: muted)[Explore the data, figures and downloads at activeattackdata.org. Attackers are never named.]
]
')

writeLines(typ, out_typ)

#--compile----------------------------------------------------------------------

res <- system2("quarto",
               c("typst", "compile", "--root", ".", "--font-path", "fact_sheet/fonts", out_typ, out_pdf),
               stdout = TRUE, stderr = TRUE)
if (!is.null(attr(res, "status"))) stop(paste(res, collapse = "\n"))
message("Wrote ", out_pdf)

# page-1 thumbnail for the download panel on the Fact Sheet tab (poppler's pdftoppm)
res <- system2("pdftoppm", c("-png", "-r", "40", "-f", "1", "-l", "1", "-singlefile",
                             out_pdf, "www/fact_sheet_preview"), stdout = TRUE, stderr = TRUE)
if (!is.null(attr(res, "status"))) warning("Preview not made: ", paste(res, collapse = " "))
