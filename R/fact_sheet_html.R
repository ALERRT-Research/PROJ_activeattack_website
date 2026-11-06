#==============================================================================
# fact_sheet_html.R
#
# Turns the table from fact_sheet_stats() into plain HTML for the Fact Sheet tab
# in 1_visuals.qmd. No packages beyond the tidyverse/scales/glue already loaded
# by 0_set_up.R, so the CI runner and renv.lock are untouched.
#
# Design: docs/logs/plans/2026-11-06_fact-sheet-design.md. Kept deliberately
# plain (Carpe Audience-like): bars start at zero and carry their own value
# labels; maroon means "latest year" and nothing else.
#
# Class names (styled in dashboard.css, scoped to #fact-sheet):
#   .fs-tiles / .fs-tile          headline comparison boxes
#   .fs-bars / .fs-bar-row        three bars per box: prev, curr, avg
#   .fs-scroll > table.fs-table   one table per section
#   tr.fs-group                   subheading row (e.g. "Race")
#   tr.fs-subtotal                subheading with numbers ("Before police arrived")
#   .fs-curr                      the latest-year column
#   .fs-pct / .fs-avg / .fs-prev  percentage, window-average and prior-year columns
#                                 (hidden on phones; average is in the boxes)
#==============================================================================

fs_fmt_n <- function(x, kind = "count") {
  ifelse(kind == "median", scales::number(x, accuracy = 1),
         scales::comma(x, accuracy = 1))
}

fs_fmt_change <- function(x) {
  case_when(is.na(x) ~ "",
            x > 0    ~ paste0("+", scales::comma(x, accuracy = 1)),
            x < 0    ~ paste0("&minus;", scales::comma(abs(x), accuracy = 1)),
            TRUE     ~ "0")
}

#--headline boxes---------------------------------------------------------------

# one box: a title, the latest-year figure, an optional note, and three bars
# from zero (prev year, latest year, window average) on the box's own scale
fs_tile <- function(title, big, note = NULL, vals, labels, val_text) {
  w <- 100 * vals / max(vals, na.rm = TRUE)
  cls <- c("fs-bar-prev", "fs-bar-curr", "fs-bar-avg")
  rows <- paste0(
    '<div class="fs-bar-row ', cls, '">',
    '<span class="fs-bar-label">', labels, '</span>',
    '<span class="fs-bar-track"><span class="fs-bar" style="width:',
    sprintf("%.1f", w), '%"></span></span>',
    '<span class="fs-bar-val">', val_text, '</span></div>',
    collapse = "")
  aria <- paste(paste0(gsub("&ndash;", " to ", labels), ": ",
                       gsub("&nbsp;|%", "", val_text)), collapse = "; ")
  paste0(
    '<section class="fs-tile">',
    '<h3 class="fs-tile-title">', title, '</h3>',
    '<p class="fs-tile-value">', big, '</p>',
    if (!is.null(note)) paste0('<p class="fs-tile-note">', note, '</p>') else '',
    '<div class="fs-bars" role="img" aria-label="', aria, '">', rows, '</div>',
    '</section>')
}

fs_tiles_html <- function(fs, map_src = "www/map_latest_year.svg") {

  yrs <- attr(fs, "years")
  g   <- function(item, col) fs[[col]][fs$item == item][1]
  labels <- c(yrs$prev, yrs$curr,
              glue("{yrs$window[1]}&ndash;{substr(yrs$window[2], 3, 4)} avg."))

  count_tile <- function(title, item) {
    v <- c(g(item, "n_prev"), g(item, "n_curr"), g(item, "avg_window"))
    fs_tile(title, scales::comma(v[2]), NULL, v, labels,
            c(scales::comma(v[1]), scales::comma(v[2]), scales::number(v[3], accuracy = 0.1)))
  }

  # resolution before police arrival moves with the number of attacks, so this
  # box shows the share (count beside it) rather than the raw count
  pre <- c(g("Before police arrived", "n_prev"), g("Before police arrived", "n_curr"),
           g("Before police arrived", "avg_window"))
  tot <- c(g("Active attacks", "n_prev"), g("Active attacks", "n_curr"),
           g("Active attacks", "avg_window"))
  share <- 100 * pre / tot
  pct   <- paste0(scales::number(share, accuracy = 1), "%")

  tiles <- c(
    count_tile(glue("Active attacks in {yrs$curr}"), "Active attacks"),
    count_tile(glue("Killed in {yrs$curr}"),         "Killed"),
    count_tile(glue("Wounded in {yrs$curr}"),        "Wounded"),
    fs_tile(glue("Ended before police arrived, {yrs$curr}"), pct[2],
            glue("{pre[2]} of {tot[2]} attacks"), share, labels, pct)
  )

  # the latest-year map sits beside the boxes (see plots_latest_year_map.R in
  # PROJ_activeattack_graphics); boxes are 2 x 2 so the two blocks match in height
  n <- scales::comma(tot[2])
  map <- paste0(
    '<figure class="fs-map">',
    '<h3 class="fs-tile-title">Where the ', n, ' attacks in ', yrs$curr, ' happened</h3>',
    '<img src="', map_src, '" alt="Map of the United States with one dot for each of the ',
    n, ' active attacks in ', yrs$curr, '">',
    '<figcaption class="fs-tile-note">One dot per attack; attacks in the same place overlap.</figcaption>',
    '</figure>')

  knitr::asis_output(paste0('<div class="fs-lead-grid"><div class="fs-tiles">',
                            paste(tiles, collapse = ""), '</div>', map, '</div>'))
}

#--section tables---------------------------------------------------------------

# prev_col: show the prior-year count. Off on the web, where "vs. <prev>" carries
# it (Peter, 11-06); the PDF keeps it as the full reference.
fs_table_html <- function(fs, section_name, prev_col = FALSE) {

  yrs <- attr(fs, "years")
  d   <- filter(fs, section == section_name)
  ncol <- if (prev_col) 7 else 6

  head <- glue(
    '<thead><tr>',
    '<th scope="col">Category</th>',
    '<th scope="col" class="fs-num">{yrs$first}&ndash;<wbr>{yrs$curr}</th>',
    '<th scope="col" class="fs-num fs-pct">%</th>',
    if (prev_col) '<th scope="col" class="fs-num fs-prev">{yrs$prev}</th>' else '',
    '<th scope="col" class="fs-num fs-curr">{yrs$curr}</th>',
    '<th scope="col" class="fs-num">vs. {yrs$prev}</th>',
    '<th scope="col" class="fs-num fs-avg">{yrs$window[1]}&ndash;<wbr>{substr(yrs$window[2], 3, 4)} avg.</th>',
    '</tr></thead>')

  rows <- character()
  last_group <- ""

  for (i in seq_len(nrow(d))) {
    r <- d[i, ]
    subtotal <- !is.na(r$group) && r$item == r$group

    if (!is.na(r$group) && r$group != last_group && !subtotal) {
      rows <- c(rows, glue('<tr class="fs-group"><th colspan="{ncol}" scope="colgroup">{r$group}</th></tr>'))
    }
    if (!is.na(r$group)) last_group <- r$group

    pct <- if (r$kind == "count") scales::number(r$pct_all, accuracy = 0.1) else ""
    avg <- if (r$kind == "median") fs_fmt_n(r$avg_window, r$kind)
           else scales::number(r$avg_window, accuracy = 0.1, big.mark = ",")

    rows <- c(rows, glue(
      '<tr{if (subtotal) " class=\\"fs-subtotal\\"" else ""}>',
      '<th scope="row">{gsub("/", "/<wbr>", r$item, fixed = TRUE)}</th>',
      '<td class="fs-num">{fs_fmt_n(r$n_all, r$kind)}</td>',
      '<td class="fs-num fs-pct">{pct}</td>',
      if (prev_col) '<td class="fs-num fs-prev">{fs_fmt_n(r$n_prev, r$kind)}</td>' else '',
      '<td class="fs-num fs-curr">{fs_fmt_n(r$n_curr, r$kind)}</td>',
      '<td class="fs-num">{fs_fmt_change(r$change)}</td>',
      '<td class="fs-num fs-avg">{avg}</td>',
      '</tr>'))
  }

  # data-quarto-disable-processing stops Quarto adding Bootstrap's striped/small
  # table classes, which fight the hairline-and-band design
  html <- paste0('<div class="fs-scroll"><table class="fs-table" data-quarto-disable-processing="true">', head, '<tbody>',
                 paste(rows, collapse = ""), '</tbody></table></div>')
  knitr::asis_output(html)
}
