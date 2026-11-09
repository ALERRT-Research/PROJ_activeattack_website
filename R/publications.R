#==============================================================================
# publications.R: render data/publications.yml on the Publications page.
# Entries are grouped by type, newest first, as a plain reference list with
# a link (DOI preferred) and a muted line on how each work used the data.
#==============================================================================

pub_types <- c(article = "Journal articles", report = "Reports", book = "Books",
               chapter = "Book chapters", other = "Other writing")

publications_load <- function(path) {
  p <- yaml::read_yaml(path)
  tibble::tibble(
    type    = purrr::map_chr(p, "type"),
    year    = purrr::map_int(p, ~ as.integer(.x$year)),
    authors = purrr::map_chr(p, "authors"),
    title   = purrr::map_chr(p, "title"),
    venue   = purrr::map_chr(p, ~ .x$venue %||% ""),
    doi     = purrr::map_chr(p, ~ .x$doi %||% ""),
    url     = purrr::map_chr(p, ~ .x$url %||% ""),
    uses    = purrr::map_chr(p, ~ .x$uses %||% ""),
    by      = purrr::map_chr(p, ~ .x$by %||% "alerrt"))
}

publications_html <- function(d) {
  esc <- htmltools::htmlEscape
  link <- function(doi, url) {
    if (nzchar(doi)) sprintf('<a href="https://doi.org/%s" target="_blank" rel="noopener">doi:%s</a>', esc(doi), esc(doi))
    else if (nzchar(url)) sprintf('<a href="%s" target="_blank" rel="noopener">%s</a>', esc(url),
                                  esc(sub("^https?://(www\\.)?([^/]+).*$", "\\2", url)))
    else ""
  }
  one <- function(r) {
    paste0('<li class="pub">',
           '<div class="pub-ref">', esc(r$authors), ' (', r$year, '). ',
           '<span class="pub-title">', esc(r$title), '.</span> ',
           if (nzchar(r$venue)) paste0('<em>', esc(r$venue), '</em>. ') else '',
           link(r$doi, r$url), '</div>',
           if (nzchar(r$uses)) paste0('<div class="pub-uses">', esc(r$uses), '</div>') else '',
           '</li>')
  }
  out <- character()
  for (t in names(pub_types)) {
    g <- d[d$type == t, ]
    if (!nrow(g)) next
    g <- g[order(-g$year, g$authors), ]
    items <- paste(purrr::map_chr(seq_len(nrow(g)), \(i) one(g[i, ])), collapse = "")
    out <- c(out, paste0('<section class="pub-group" id="', t, '"><h2 class="pub-h2">', pub_types[[t]],
                         ' <span class="pub-count">', nrow(g), '</span></h2><ul class="pub-list">', items, '</ul></section>'))
  }
  knitr::asis_output(paste(out, collapse = ""))
}
