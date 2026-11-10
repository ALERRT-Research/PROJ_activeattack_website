#==============================================================================
# codebook.R
#
# The codebook for the Active Attack Data, built from the published data and
# the variable labels DATA_aa exports (data/aa_data_wide_labels_<version>.csv).
# Shared by the Codebook page (codebook.qmd) and the PDF (R/codebook_pdf.R),
# so the two never disagree. No labels live here: edit them in DATA_aa
# (code/codebook_events.R) and rerun its export.
#
#   codebook_rows(d, labels)  one row per variable: group, label, type, values,
#                             missing
#   codebook_html(rows)       the page body, one table per group
#   aa_citation(version, released)  suggested citation (text and BibTeX)
#==============================================================================

# variables in the order the codebook presents them; anything in the data but
# not listed lands in "Other" so nothing is dropped silently
codebook_groups <- list(
  "When" = c("case_code", "date", "year", "month", "day", "hour"),
  "Where" = c("zip_code", "city", "state", "location_primary", "school_level",
              "escalated", "mobile"),
  "Attackers" = c("offender_count", "relationship", paste0("age_", 1:3),
                  paste0("sex_", 1:3), paste0("race_", 1:3)),
  "Weapons" = c("weapon_primary", "weapon_pistol_tot", "weapon_shotgun_tot",
                "weapon_rifle_tot", "weapon_tot"),
  "People shot, wounded and killed" = c(
    "shot_tot", "shot_tot_incl", "shot_cit_tot", "shot_le_tot", "shot_guard_tot",
    "wound_tot", "wound_tot_incl", "wound_cit_tot", "wound_le_tot", "wound_guard_tot",
    "kill_tot", "kill_tot_incl", "kill_cit_tot", "kill_le_tot", "kill_guard_tot"),
  "How the attack ended" = c("resolution", "resolved_pre_le"))

# plain-language notes that the one-line labels cannot carry
codebook_notes <- c(
  case_code       = "Identifier, not a running count: cases removed on review leave gaps.",
  zip_code        = "ZIP code nearest the attack, kept as text so leading zeros survive.",
  school_level    = "Only recorded when location_primary is School.",
  shot_tot_incl   = "Inclusive (FBI) definition; see the note on _incl variables.",
  wound_tot_incl  = "Inclusive (FBI) definition; see the note on _incl variables.",
  kill_tot_incl   = "Inclusive (FBI) definition; see the note on _incl variables.",
  resolved_pre_le = "Attackers who fled are counted as resolved before police arrived.",
  age_1           = "Attacker order is arbitrary; _2 and _3 are empty for one-attacker events.")

codebook_rows <- function(d, labels) {
  stopifnot(all(c("variable", "label") %in% names(labels)))
  listed  <- unlist(codebook_groups, use.names = FALSE)
  missing <- setdiff(listed, names(d))
  if (length(missing)) stop("codebook_groups names variables not in the data: ",
                            paste(missing, collapse = ", "))
  groups <- codebook_groups
  extra  <- setdiff(names(d), listed)
  if (length(extra)) groups[["Other"]] <- extra

  n <- nrow(d)
  one <- function(group, v) {
    x    <- d[[v]]
    lab  <- labels$label[match(v, labels$variable)]
    note <- unname(codebook_notes[v])
    if (is.na(note) && "note" %in% names(labels)) {
      note <- labels$note[match(v, labels$variable)]
      if (!is.na(note) && !nzchar(note)) note <- NA_character_
    }
    nmiss <- sum(is.na(x) | (is.character(x) & !is.na(x) & trimws(x) == ""))
    ok    <- x[!is.na(x)]
    nuniq <- length(unique(ok))
    levels_tbl <- NULL
    if (inherits(x, "Date")) {
      type   <- "Date"
      values <- paste(format(range(ok), "%Y-%m-%d"), collapse = " to ")
    } else if (is.factor(x)) {
      type   <- "Category"
      tb     <- table(x, useNA = "no")
      levels_tbl <- data.frame(level = names(tb), n = as.integer(tb))
      values <- NA_character_
    } else if (is.numeric(x)) {
      if (v == "case_code" || nuniq == n) {
        type <- "Identifier"; values <- paste(range(ok), collapse = " to ")
      } else {
        type   <- "Number"
        # no thousands separator: years would read 2,025
        values <- sprintf("%s to %s, median %s", min(ok), max(ok),
                          format(stats::median(ok), digits = 3))
      }
    } else if (is.character(x) && nuniq <= 12) {
      numlike <- all(grepl("^-?[0-9.]+$", ok))
      type    <- if (numlike) "Count (as text)" else "Category (as text)"
      tb      <- table(ok)
      lv      <- names(tb)
      ord     <- if (numlike) order(as.numeric(lv)) else order(-as.integer(tb))
      levels_tbl <- data.frame(level = lv[ord], n = as.integer(tb)[ord])
      values  <- NA_character_
    } else {
      type   <- if (v == "case_code") "Identifier" else "Text"
      values <- sprintf("%s distinct values", scales::comma(nuniq))
    }
    tibble::tibble(group = group, variable = v, label = lab, note = note,
                   type = type, values = values, levels = list(levels_tbl),
                   n_missing = nmiss, pct_missing = 100 * nmiss / n)
  }
  purrr::list_rbind(purrr::imap(groups, \(vars, g) purrr::list_rbind(purrr::map(vars, \(v) one(g, v)))))
}

#--HTML-------------------------------------------------------------------------

codebook_html <- function(rows) {
  esc <- htmltools::htmlEscape
  fmt_levels <- function(lv) {
    if (is.null(lv)) return("")
    paste0('<ul class="cb-levels">',
           paste0('<li>', esc(lv$level), ' <span>', scales::comma(lv$n), '</span></li>', collapse = ""),
           '</ul>')
  }
  fmt_missing <- function(nm, pct) {
    if (nm == 0) '<span class="cb-none">none</span>'
    else sprintf('%s <span class="cb-pct">(%s%%)</span>', scales::comma(nm),
                 scales::number(pct, accuracy = if (pct < 1) 0.1 else 1))
  }
  one_group <- function(g, r) {
    body <- paste0(
      '<tr id="var-', esc(r$variable), '">',
      '<td class="cb-var"><code>', esc(r$variable), '</code>',
      '<div class="cb-label">', esc(r$label), '</div>',
      ifelse(is.na(r$note), '', paste0('<div class="cb-note">', esc(r$note), '</div>')),
      '</td>',
      '<td class="cb-type">', esc(r$type), '</td>',
      '<td class="cb-values">', ifelse(is.na(r$values), purrr::map_chr(r$levels, fmt_levels), esc(r$values)), '</td>',
      '<td class="cb-missing">', purrr::map2_chr(r$n_missing, r$pct_missing, fmt_missing), '</td>',
      '</tr>', collapse = "")
    id <- gsub("[^a-z0-9]+", "-", tolower(g))
    paste0('<section class="cb-group" id="', id, '">',
           '<h2 class="cb-h2">', esc(g), ' <span class="cb-count">', nrow(r),
           ifelse(nrow(r) == 1, ' variable', ' variables'), '</span></h2>',
           '<table class="cb-table"><thead><tr>',
           '<th>Variable</th><th>Type</th><th>Values</th><th>Missing</th>',
           '</tr></thead><tbody>', body, '</tbody></table></section>')
  }
  groups <- split(rows, factor(rows$group, levels = unique(rows$group)))
  knitr::asis_output(paste0(purrr::imap_chr(groups, \(r, g) one_group(g, r)), collapse = ""))
}

# the group list for a page's jump links
codebook_nav_html <- function(rows) {
  g  <- unique(rows$group)
  id <- gsub("[^a-z0-9]+", "-", tolower(g))
  knitr::asis_output(paste0('<nav class="cb-nav" aria-label="Variable groups">',
                            paste0('<a href="#', id, '">', htmltools::htmlEscape(g), '</a>', collapse = ""),
                            '</nav>'))
}

#--citation-----------------------------------------------------------------------

# release year is the citation year; the version is the data year
# APA-style data set citation in four forms (markdown, html, plain, BibTeX).
# Used for the Active Attack Data and for the related datasets on datasets.qmd.
dataset_citation <- function(title, key, version, year, url = "https://activeattackdata.org") {
  list(
    text = glue::glue(
      "Advanced Law Enforcement Rapid Response Training (ALERRT) Center. ({year}). ",
      "*{title}* (Version {version}) [Data set]. Texas State University. ",
      "{url}"),
    html = glue::glue(
      "Advanced Law Enforcement Rapid Response Training (ALERRT) Center. ({year}). ",
      "<em>{title}</em> (Version {version}) [Data set]. Texas State University. ",
      "<a href=\"{url}\">{url}</a>"),
    plain = glue::glue(
      "Advanced Law Enforcement Rapid Response Training (ALERRT) Center. ({year}). ",
      "{title} (Version {version}) [Data set]. Texas State University. ",
      "{url}"),
    bibtex = glue::glue(
      "@misc{{{key}_{version},\n",
      "  author       = {{{{Advanced Law Enforcement Rapid Response Training (ALERRT) Center}}}},\n",
      "  title        = {{{title}}},\n",
      "  year         = {{{year}}},\n",
      "  version      = {{{version}}},\n",
      "  publisher    = {{Texas State University}},\n",
      "  howpublished = {{\\url{{{url}}}}},\n",
      "  note         = {{Data set}}\n",
      "}}"))
}

aa_citation <- function(version, released) {
  dataset_citation("Active Attack Data", "alerrt_active_attack_data", version,
                   format(as.Date(released), "%Y"))
}
