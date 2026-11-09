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
# an image in both themes: www/<file> and www/dark/<file>, Quarto shows one
aa_img_pair <- function(src, alt, class = "") {
  dark <- sub("^www/", "www/dark/", src)
  paste0('<img class="light-content ', class, '" src="', src, '" alt="', alt, '">',
         '<img class="dark-content ', class, '" src="', dark, '" alt="', alt, '">')
}

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

# Home: the hero band (title, purpose, headline numbers, latest-year map)
home_hero <- function(d) {
  yrs <- range(d$year, na.rm = TRUE)
  stats <- setNames(
    c(scales::comma(nrow(d)), scales::comma(sum(d$kill_tot, na.rm = TRUE)),
      scales::comma(sum(d$wound_tot, na.rm = TRUE))),
    c("active attacks", "people killed", "people wounded"))
  n_latest <- sum(d$year == yrs[2], na.rm = TRUE)
  knitr::asis_output(paste0(
    '<div class="aa-hero-inner">',
    '<div class="aa-hero-text">',
    '<p class="aa-hero-kicker">ALERRT Center, Texas State University</p>',
    '<h1 class="aa-hero-title">Active Attack Data Explorer</h1>',
    '<p class="aa-hero-lead">Every active attack in the United States from ', yrs[1], ' through ', yrs[2],
    ': when and where they happened, who carried them out, and the people killed and wounded. ',
    'Free to explore, download and cite.</p>',
    aa_stats_html(stats),
    '</div>',
    '<figure class="aa-hero-map">',
    aa_img_pair("www/map_latest_year.svg", paste0("Map of the United States with one dot for each of the ",
                n_latest, " active attacks in ", yrs[2])),
    '<figcaption>The ', n_latest, ' attacks in ', yrs[2], ', one dot each</figcaption>',
    '</figure>',
    '</div>'))
}

# Home: cards into each dashboard tab, plus Remembrance and Contact
home_cards <- function(d) {
  yrs <- range(d$year, na.rm = TRUE)
  links <- data.frame(
    href  = c("1_visuals.html#timing", "1_visuals.html#attackers", "1_visuals.html#locations",
              "1_visuals.html#casualties", "1_visuals.html#across-the-usa", "1_visuals.html#fact-sheet",
              "1_visuals.html#download-the-data", "2_victims.html"),
    title = c("Timing", "Attackers", "Locations", "Casualties", "Across the USA", "Fact Sheet",
              "Download the Data", "Remembrance"),
    text  = c("By year, month, day of the week and hour",
              "Who carried out the attacks, and their weapons",
              "Where attacks happened, and the attacker's tie to the place",
              "People killed and wounded",
              "Attacks and fatalities by state",
              paste0("The key numbers for ", yrs[2], ", with a PDF to share"),
              "The full dataset, its codebook, and how to cite it",
              "The names of the people who were killed"),
    col   = c("var(--aa-tab-timing)", "var(--aa-tab-attackers)", "var(--aa-tab-locations)",
              "var(--aa-tab-casualties)", "var(--aa-ink)", "var(--aa-ink)", "var(--aa-ink)", "var(--aa-ink)"))
  cards <- paste0('<a class="aa-home-link" href="', links$href,
                  '" style="--aa-tab:', links$col, '"><strong>', links$title,
                  '</strong><span>', links$text, '</span></a>', collapse = "")
  knitr::asis_output(paste0('<nav class="aa-home-links" aria-label="Explore the data">', cards, '</nav>'))
}

# Home: the latest year at a glance (numbers from fact_sheet_stats())
home_latest <- function(fs) {
  yrs <- attr(fs, "years")
  g   <- function(item, col) fs[[col]][fs$item == item][1]
  pre <- g("Before police arrived", "n_curr"); tot <- g("Active attacks", "n_curr")
  stats <- setNames(
    c(tot, g("Killed", "n_curr"), g("Wounded", "n_curr"), paste0(round(100 * pre / tot), "%")),
    c(glue::glue("attacks ({g('Active attacks', 'n_prev')} in {yrs$prev})"),
      glue::glue("killed ({g('Killed', 'n_prev')} in {yrs$prev})"),
      glue::glue("wounded ({g('Wounded', 'n_prev')} in {yrs$prev})"),
      "ended before police arrived"))
  knitr::asis_output(paste0(
    '<div class="aa-latest-strip">',
    '<h2 class="aa-latest-title">', yrs$curr, ' at a glance</h2>',
    aa_stats_html(stats, latest = names(stats)),
    '</div>'))
}

# Remembrance: every recorded name, newest year first, then by attack date.
# Officers and minors carry a small text label (not colour alone). No attacker
# is ever named on this site; this list holds victims only.
remembrance_names <- function(v) {
  esc <- function(x) htmltools::htmlEscape(x)
  v <- v |>
    dplyr::filter(!is.na(victim), trimws(victim) != "") |>
    dplyr::mutate(victim = trimws(victim),
                  year = as.integer(format(date, "%Y")),
                  last_first = dplyr::coalesce(unname(name_last_first), victim)) |>
    dplyr::arrange(dplyr::desc(year), date, last_first)
  years <- sort(unique(v$year), decreasing = TRUE)

  nav <- paste0('<nav class="rem-years" aria-label="Jump to a year">',
                paste0('<a href="#y', years, '">', years, '</a>', collapse = ""), '</nav>')

  body <- vapply(years, function(y) {
    vy <- v[v$year == y, ]
    dates <- unique(vy$date)
    blocks <- vapply(seq_along(dates), function(i) {
      vd <- vy[vy$date == dates[i], ]
      tags <- ifelse(vd$le == "Yes", ' <span class="rem-tag">Officer</span>', "")
      tags <- paste0(tags, ifelse(vd$minor == "Yes", ' <span class="rem-tag rem-minor">Under 18</span>', ""))
      paste0('<div class="rem-date"><h3>', format(dates[i], "%B %e"), '</h3><ul class="rem-names">',
             paste0('<li>', esc(vd$victim), tags, '</li>', collapse = ""), '</ul></div>')
    }, character(1))
    paste0('<section class="rem-year" id="y', y, '"><h2>', y, ' <span class="rem-count">',
           nrow(vy), if (nrow(vy) == 1) ' person' else ' people', '</span></h2>',
           paste(blocks, collapse = ""), '</section>')
  }, character(1))

  knitr::asis_output(paste0(
    '<div class="rem-tools">',
    '<label class="visually-hidden" for="rem-search">Find a name</label>',
    '<input id="rem-search" class="rem-search" type="search" placeholder="Find a name" autocomplete="off">',
    '<p class="rem-match" aria-live="polite"></p>',
    nav, '</div>',
    '<div class="rem-list">', paste(body, collapse = ""), '</div>'))
}
