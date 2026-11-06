#==============================================================================
# check_fact_sheet_v2025.R
#
# One-off reconciliation: computed cumulative counts vs the hand-typed v2025
# fact sheet (1_visuals.qmd and data/aa_fact_sheet_2025.pdf, as of 2026-11-06).
# Run from the project root before the hand-typed list is removed:
#   Rscript R/check_fact_sheet_v2025.R
#==============================================================================

suppressMessages({library(dplyr); library(purrr); library(tibble)})
source("R/fact_sheet_stats.R")

aa_data <- readRDS("data/aa_data_wide_nogeo_2025.rds")
fs <- fact_sheet_stats(aa_data)

published <- tribble(
  ~item,                            ~published,
  "Active attacks",                 634,
  "Firearm",                        591,
  "Blade",                          30,
  "Vehicle",                        13,
  "Pistol",                         347,
  "Rifle",                          185,
  "Shotgun",                        53,
  "Unknown",                        6,      # firearm type
  "1 attacker",                     619,
  "2 attackers",                    12,
  "3 attackers",                    3,
  "African American",               185,
  "Asian",                          22,
  "Caucasian",                      299,
  "Latino",                         86,
  "Middle Eastern",                 18,
  "Other",                          4,
  "No relationship",                415,
  "Employee/former employee",       99,
  "Student/former student",         72,
  "All other",                      48,     # relationship
  "Business",                       283,
  "School",                         85,
  "Public/outdoors",                175,
  "Church",                         22,
  "Military base",                  7,
  "Before police arrived",          374,
  "Shot by civilian",               29,
  "Subdued by civilian",            60,
  "Suicide before police arrival",  87,
  "Fled the scene",                 198,
  "After police arrived",           260,
  "Shot by police",                 138,
  "Subdued by police",              57,
  "Suicide after police arrival",   49,
  "Surrendered",                    16,
  "Total victims",                  4287,
  "Wounded",                        2810,
  "Killed",                         1477,
  "Median victims per attack",      4,
  "Median wounded per attack",      2,
  "Median killed per attack",       1
)

# "Unknown" and "All other" appear in more than one section; match the right one
fs_check <- fs |>
  filter(!(item == "Unknown"   & group == "Race"),
         !(item == "All other" & section == "Locations"))

cmp <- published |>
  left_join(select(fs_check, item, computed = n_all), by = "item") |>
  mutate(ok = computed == published)

# multiple weapons is published as a percent only
mw <- fs$pct_all[fs$item == "Multiple weapons used"]
cmp <- bind_rows(cmp, tibble(item = "Multiple weapons used (%)", published = 30.28,
                             computed = round(mw, 2), ok = round(mw, 2) == 30.28))

print(filter(cmp, !ok), n = Inf)
cat(sum(cmp$ok), "of", nrow(cmp), "published values reproduced\n")
