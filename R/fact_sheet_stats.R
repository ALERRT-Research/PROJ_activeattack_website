#==============================================================================
# fact_sheet_stats.R
#
# Computes every number on the Active Attack fact sheet from the released wide
# data, plus the year-over-year comparison. One source for both the website's
# Fact Sheet tab (1_visuals.qmd) and the PDF (fact_sheet_pdf.qmd).
#
# Usage (after 0_set_up.R, which loads the tidyverse):
#   source("R/fact_sheet_stats.R")
#   fs <- fact_sheet_stats(aa_data)
#
# Output: one row per fact-sheet line
#   section, group, item, kind   labels; kind is "count", "sum" or "median"
#   n_all, pct_all               2000 through the latest year (pct of denominator)
#   n_prev, n_curr               the year before the latest, and the latest year
#   change                       n_curr - n_prev
#   avg_window                   mean per year over the n_avg years before the
#                                latest (for medians: median of the pooled events)
#
# Single years are small (29-62 attacks), so the yearly columns are counts only;
# percentages are reported for the cumulative column. Both years come from the
# CURRENT data version, so events added after the fact land in the right year.
#
# Plan: docs/logs/plans/2026-11-06_fact-sheet-retool.md
#==============================================================================

#--category definitions--------------------------------------------------------
# Kept here once so the page, the PDF and the reconciliation check agree.

fs_business  <- c("Office", "Factory/warehouse", "Retail", "Medical facility")
fs_firearms  <- c("Pistol", "Rifle", "Shotgun")
fs_civilian_shot <- c("Shot by citizen", "Shot by off duty officer", "Shot by security")

#--per-subset tally------------------------------------------------------------
# Returns section/group/item/kind/n/denom for one slice of the data. Every
# item is defined as a logical vector over events (counts), a numeric vector to
# sum (victims), or a numeric vector to take the median of.

fs_tally <- function(d) {

  N <- nrow(d)

  # weapon_primary is NA only when the firearm type is unknown (6 events in
  # v2025, all firearms); the published fact sheet counts them as firearms
  firearm <- d$weapon_primary %in% fs_firearms | is.na(d$weapon_primary)
  n_fire  <- sum(firearm)

  race <- as.character(d$race_1)
  race[is.na(race)] <- "Unknown"

  rel <- as.character(d$relationship)
  loc <- as.character(d$location_primary)
  res <- d$resolution

  pre_le  <- res %in% c(fs_civilian_shot, "Subdued by citizens",
                        "Suicide before police arrival", "Fled")
  post_le <- res %in% c("Shot by police", "Subdued by police",
                        "Suicide after police arrival", "Surrendered")

  victims <- d$wound_tot + d$kill_tot

  cnt <- function(section, item, x, denom = N, group = NA_character_) {
    tibble(section = section, group = group, item = item, kind = "count",
           n = sum(x, na.rm = TRUE), denom = denom)
  }
  tot <- function(section, item, x) {
    tibble(section = section, group = NA_character_, item = item, kind = "sum",
           n = sum(x, na.rm = TRUE), denom = NA_real_)
  }
  med <- function(section, item, x) {
    tibble(section = section, group = NA_character_, item = item, kind = "median",
           n = if (length(x)) median(x, na.rm = TRUE) else NA_real_, denom = NA_real_)
  }

  bind_rows(
    cnt("Overview", "Active attacks", rep(TRUE, N)),

    # Weapons
    cnt("Weapons", "Firearm", firearm,                          group = "Primary weapon"),
    cnt("Weapons", "Blade",   d$weapon_primary %in% "Knife",    group = "Primary weapon"),
    cnt("Weapons", "Vehicle", d$weapon_primary %in% "Vehicle",  group = "Primary weapon"),
    cnt("Weapons", "More than one weapon", d$weapon_tot > 1, group = "Weapons per attack"),
    cnt("Weapons", "Pistol",  firearm & d$weapon_primary %in% "Pistol",  n_fire, "Firearm type"),
    cnt("Weapons", "Rifle",   firearm & d$weapon_primary %in% "Rifle",   n_fire, "Firearm type"),
    cnt("Weapons", "Shotgun", firearm & d$weapon_primary %in% "Shotgun", n_fire, "Firearm type"),
    cnt("Weapons", "Unknown", firearm & is.na(d$weapon_primary),         n_fire, "Firearm type"),

    # Attackers (race is the first-listed attacker, as on the published sheet)
    cnt("Attackers", "1 attacker",  d$offender_count == 1, group = "Number of attackers"),
    cnt("Attackers", "2 attackers", d$offender_count == 2, group = "Number of attackers"),
    cnt("Attackers", "3 attackers", d$offender_count == 3, group = "Number of attackers"),
    map_dfr(c("African American", "Asian", "Caucasian", "Latino",
              "Middle Eastern", "Other", "Unknown"),
            \(r) cnt("Attackers", r, race == r, group = "Race")),
    cnt("Attackers", "No relationship",          rel %in% "No relationship", group = "Relationship to victims"),
    cnt("Attackers", "Employee/former employee", rel %in% "Coworker",        group = "Relationship to victims"),
    cnt("Attackers", "Student/former student",   rel %in% "Student",         group = "Relationship to victims"),
    cnt("Attackers", "All other",
        !rel %in% c("No relationship", "Coworker", "Student"),               group = "Relationship to victims"),

    # Locations ("Church" and "Military base" appear only if DATA_aa keeps them
    # as levels; until then they are inside "All other")
    cnt("Locations", "Business",        loc %in% fs_business),
    cnt("Locations", "School",          loc %in% "School"),
    cnt("Locations", "Public/outdoors", loc %in% "Outdoors"),
    cnt("Locations", "Church",          loc %in% "Church"),
    cnt("Locations", "Military base",   loc %in% "Military base"),
    cnt("Locations", "All other",
        !loc %in% c(fs_business, "School", "Outdoors", "Church", "Military base")),

    # Resolution: grouped by the resolution itself, as on the published sheet
    # (not resolved_pre_le, which places 6 fled-after-arrival events "after")
    cnt("Resolution", "Before police arrived",          pre_le,                                     group = "Before police arrived"),
    cnt("Resolution", "Shot by civilian",               res %in% fs_civilian_shot,                  group = "Before police arrived"),
    cnt("Resolution", "Subdued by civilian",            res %in% "Subdued by citizens",             group = "Before police arrived"),
    cnt("Resolution", "Suicide before police arrival",  res %in% "Suicide before police arrival",   group = "Before police arrived"),
    cnt("Resolution", "Fled the scene",                 res %in% "Fled",                            group = "Before police arrived"),
    cnt("Resolution", "After police arrived",           post_le,                                    group = "After police arrived"),
    cnt("Resolution", "Shot by police",                 res %in% "Shot by police",                  group = "After police arrived"),
    cnt("Resolution", "Subdued by police",              res %in% "Subdued by police",               group = "After police arrived"),
    cnt("Resolution", "Suicide after police arrival",   res %in% "Suicide after police arrival",    group = "After police arrived"),
    cnt("Resolution", "Surrendered",                    res %in% "Surrendered",                     group = "After police arrived"),

    # Victims
    tot("Victims", "Total victims", victims),
    tot("Victims", "Wounded",       d$wound_tot),
    tot("Victims", "Killed",        d$kill_tot),
    med("Victims", "Median victims per attack", victims),
    med("Victims", "Median wounded per attack", d$wound_tot),
    med("Victims", "Median killed per attack",  d$kill_tot)
  )
}

#--main------------------------------------------------------------------------

fact_sheet_stats <- function(d, curr_year = max(d$year, na.rm = TRUE), n_avg = 5) {

  prev_year   <- curr_year - 1
  window      <- (curr_year - n_avg):(curr_year - 1)
  d           <- filter(d, year <= curr_year)

  key <- c("section", "group", "item", "kind")

  all  <- fs_tally(d)
  prev <- fs_tally(filter(d, year == prev_year)) |> select(all_of(key), n_prev = n)
  curr <- fs_tally(filter(d, year == curr_year)) |> select(all_of(key), n_curr = n)

  # window average: mean of per-year values, zeros included; medians pooled
  per_year <- map_dfr(window, \(y) fs_tally(filter(d, year == y)) |> mutate(year = y))
  avg <- per_year |>
    filter(kind != "median") |>
    summarise(avg_window = mean(n), .by = all_of(key))
  avg_med <- fs_tally(filter(d, year %in% window)) |>
    filter(kind == "median") |>
    select(all_of(key), avg_window = n)

  out <- all |>
    mutate(pct_all = if_else(kind == "count", 100 * n / denom, NA_real_)) |>
    select(all_of(key), n_all = n, pct_all) |>
    left_join(prev, by = key) |>
    left_join(curr, by = key) |>
    left_join(bind_rows(avg, avg_med), by = key) |>
    mutate(change = n_curr - n_prev)

  attr(out, "years") <- list(first = min(d$year, na.rm = TRUE), curr = curr_year,
                             prev = prev_year, window = range(window))
  out
}
