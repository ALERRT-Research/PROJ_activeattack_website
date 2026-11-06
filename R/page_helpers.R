#==============================================================================
# page_helpers.R
#
# Small HTML builders for the dashboard and Home pages. Plain HTML, no new
# packages. Styles: dashboard.css (.aa-head) and styles.css (.aa-home-*).
# Plan: docs/logs/plans/2026-11-06_page-format.md
#==============================================================================

# key numbers: a named character vector, names are the labels, e.g.
#   c("Attacks, 2000-2025" = "634", "In 2025" = "37")
# latest: names of entries to set in maroon (the latest year, as everywhere)
aa_stats_html <- function(stats, latest = character()) {
  if (!length(stats)) return("")
  cls <- ifelse(names(stats) %in% latest, ' class="aa-latest"', "")
  paste0('<dl class="aa-stats">',
         paste0('<div', cls, '><dd>', stats, '</dd><dt>', names(stats), '</dt></div>',
                collapse = ""),
         '</dl>')
}

# header for a dashboard tab: title, one-line lead, key numbers
tab_header <- function(title, lead, stats = NULL, latest = character()) {
  knitr::asis_output(paste0(
    '<div class="aa-head-inner">',
    '<div class="aa-head-text">',
    '<h2 class="aa-head-title">', title, '</h2>',
    '<p class="aa-head-lead">', lead, '</p>',
    '</div>',
    aa_stats_html(stats, latest),
    '</div>'))
}
