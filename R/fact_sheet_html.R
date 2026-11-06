#==============================================================================
# fact_sheet_html.R
#
# Turns the table from fact_sheet_stats() into plain HTML for the Fact Sheet tab
# in 1_visuals.qmd. No packages beyond the tidyverse/scales/glue already loaded
# by 0_set_up.R, so the CI runner and renv.lock are untouched.
#
# Class names (styled in styles.css):
#   table.fs-table      one table per section
#   tr.fs-group         subheading row (e.g. "Race")
#   tr.fs-subtotal      a row that is also a subheading with numbers
#                       (Resolution: "Before police arrived")
#   span.fs-pct         the percentage beside a cumulative count
#   td.fs-up / fs-down / fs-flat   direction of the change (neutral styling)
#==============================================================================

fs_fmt_n <- function(x, kind) {
  ifelse(kind == "median", scales::number(x, accuracy = 1),
         scales::comma(x, accuracy = 1))
}

fs_fmt_change <- function(x) {
  case_when(is.na(x) ~ "",
            x > 0    ~ paste0("+", scales::comma(x, accuracy = 1)),
            x < 0    ~ paste0("&minus;", scales::comma(abs(x), accuracy = 1)),
            TRUE     ~ "0")
}

fs_table_html <- function(fs, section_name) {

  yrs <- attr(fs, "years")
  d   <- filter(fs, section == section_name)

  head <- glue(
    '<thead><tr>',
    '<th scope="col">Category</th>',
    '<th scope="col" class="fs-num">{yrs$first}&ndash;{yrs$curr}</th>',
    '<th scope="col" class="fs-num">{yrs$prev}</th>',
    '<th scope="col" class="fs-num">{yrs$curr}</th>',
    '<th scope="col" class="fs-num">Change</th>',
    '<th scope="col" class="fs-num">{yrs$window[1]}&ndash;{yrs$window[2]}<br>avg./yr</th>',
    '</tr></thead>')

  rows <- character()
  last_group <- ""

  for (i in seq_len(nrow(d))) {
    r <- d[i, ]
    subtotal <- !is.na(r$group) && r$item == r$group

    if (!is.na(r$group) && r$group != last_group && !subtotal) {
      rows <- c(rows, glue('<tr class="fs-group"><th colspan="6" scope="colgroup">{r$group}</th></tr>'))
    }
    if (!is.na(r$group)) last_group <- r$group

    all_cell <- if (r$kind == "count") {
      glue('{fs_fmt_n(r$n_all, r$kind)} <span class="fs-pct">({scales::number(r$pct_all, accuracy = 0.1)}%)</span>')
    } else {
      fs_fmt_n(r$n_all, r$kind)
    }

    dir <- case_when(is.na(r$change) ~ "fs-flat", r$change > 0 ~ "fs-up",
                     r$change < 0 ~ "fs-down", TRUE ~ "fs-flat")
    avg <- if (r$kind == "median") fs_fmt_n(r$avg_window, r$kind)
           else scales::number(r$avg_window, accuracy = 0.1, big.mark = ",")

    rows <- c(rows, glue(
      '<tr{if (subtotal) " class=\\"fs-subtotal\\"" else ""}>',
      '<th scope="row">{r$item}</th>',
      '<td class="fs-num">{all_cell}</td>',
      '<td class="fs-num">{fs_fmt_n(r$n_prev, r$kind)}</td>',
      '<td class="fs-num">{fs_fmt_n(r$n_curr, r$kind)}</td>',
      '<td class="fs-num {dir}">{fs_fmt_change(r$change)}</td>',
      '<td class="fs-num">{avg}</td>',
      '</tr>'))
  }

  html <- paste0('<table class="fs-table">', head, '<tbody>',
                 paste(rows, collapse = ""), '</tbody></table>')
  knitr::asis_output(html)
}
