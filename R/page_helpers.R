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

# Home: headline numbers and links into each dashboard tab
home_front <- function(d) {
  yrs <- range(d$year, na.rm = TRUE)
  stats <- setNames(
    c(scales::comma(nrow(d)), scales::comma(sum(d$kill_tot, na.rm = TRUE)),
      scales::comma(sum(d$wound_tot, na.rm = TRUE)), paste0(yrs[1], "\u2013", yrs[2])),
    c("Active attacks", "People killed", "People wounded", "Years covered"))
  links <- data.frame(
    href  = c("timing", "attackers", "locations", "casualties", "across-the-usa", "fact-sheet", "download-the-data"),
    title = c("Timing", "Attackers", "Locations", "Casualties", "Across the USA", "Fact Sheet", "Download the Data"),
    text  = c("By year, month, day of the week and hour",
              "Who carried out the attacks, and their weapons",
              "Where attacks happened, and the attacker's tie to the place",
              "People killed and wounded",
              "Attacks and fatalities by state",
              paste0("The key numbers for ", yrs[2], ", with a PDF to share"),
              "The full dataset and codebook"),
    col   = c("#b8843f", "#3d6b9e", "#3f8a73", "#7d68ad", "#1f2a36", "#1f2a36", "#1f2a36"))
  cards <- paste0('<a class="aa-home-link" href="1_visuals.html#', links$href,
                  '" style="--aa-tab:', links$col, '"><strong>', links$title,
                  '</strong><span>', links$text, '</span></a>', collapse = "")
  knitr::asis_output(paste0('<div class="aa-home-front">', aa_stats_html(stats),
                            '<nav class="aa-home-links" aria-label="Explore the data">', cards,
                            '</nav></div>'))
}
