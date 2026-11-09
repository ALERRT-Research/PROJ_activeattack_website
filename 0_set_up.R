#install packages
library(pacman)
p_load(bslib,
       DT,
       glue,
       rio,
       scales,
       tidyverse)

# function to compare checksums -------------------------------------------
# The update_* functions copy a feeder file whenever its md5 differs from the
# local copy, in either direction of staleness. If the sibling DATA_aa or
# graphics checkout is behind the published data (2026-11-09: a Mac whose
# DATA_aa output predated the 11-06 recode silently reverted data/), render with
#   AA_SKIP_UPDATE=1 quarto render ...
# and bring the feeder repo up to date first.

copy_ifelse_checksums <- function(local_file_path, remote_file_path) {
  
  # Helper: generate file hash
  generate_file_hash <- function(file_path) {
    digest::digest(object = file_path, algo = "md5", file = TRUE)
  }
  
  # Helper: compare hashes
  compare_hashes <- function(local, remote) {
    local_hash <- generate_file_hash(local_file_path)
    remote_hash <- generate_file_hash(remote_file_path)
    identical(local_hash, remote_hash)
  }
  
  # Main logic
  if (!file.exists(local_file_path) || !compare_hashes(local_file_path, remote_file_path)) {
    file.copy(remote_file_path, local_file_path, overwrite = TRUE)
    cat("Updated local data copy.\n")
  } else {
    cat("Local data copy is up-to-date.\n")
  }
}


# set version -------------------------------------------------------------

version <- "2025"

# release history of the current version (shown on the Download tab and the
# Codebook; the Home page Updates list is the full record)
version_released  <- as.Date("2026-09-08")
version_corrected <- as.Date("2026-11-06")   # relationship recode; NA if none yet

#=import data & codebook=======================================================

update_aa_data <- function(){
  if (Sys.getenv("AA_SKIP_UPDATE") == "1") {
    message("AA_SKIP_UPDATE=1: not refreshing from the feeder repos")
    return(invisible(NULL))
  }

  
  #long + no geo
  copy_ifelse_checksums(glue("data/aa_data_long_nogeo_{version}.rds"),
                        glue("../DATA_aa/output/events/{version}/aa_data_long_nogeo_{version}.rds"))
  
  #wide + no geo
  copy_ifelse_checksums(glue("data/aa_data_wide_nogeo_{version}.rds"),
                        glue("../DATA_aa/output/events/{version}/aa_data_wide_nogeo_{version}.rds"))
  
  #codebook (.docx, kept for the record; the site builds its own from the labels)
  copy_ifelse_checksums(glue("data/aa_data_wide_codebook_{version}.docx"),
                        glue("../DATA_aa/output/codebook/{version}/aa_data_wide_codebook_{version}.docx"))

  #variable labels: the Codebook page and PDF are built from these (R/codebook.R)
  copy_ifelse_checksums(glue("data/aa_data_wide_labels_{version}.csv"),
                        glue("../DATA_aa/output/codebook/{version}/aa_data_wide_labels_{version}.csv"))
  
  #convert data to .csv for download
  aa_data <- import(glue("data/aa_data_wide_nogeo_{version}.rds", trust=TRUE))
  export(aa_data, glue("data/aa_data_wide_nogeo_{version}.csv"))
  rm(aa_data)
}

# import graphics ---------------------------------------------------------

update_aa_graphics <- function(){
  if (Sys.getenv("AA_SKIP_UPDATE") == "1") {
    message("AA_SKIP_UPDATE=1: not refreshing from the feeder repos")
    return(invisible(NULL))
  }

  
  #timing
  copy_ifelse_checksums("www/univar_yr.png",
                        "../PROJ_activeattack_graphics/output/univar_yr.png")
  copy_ifelse_checksums("www/univar_month.png",
                        "../PROJ_activeattack_graphics/output/univar_month.png")
  copy_ifelse_checksums("www/univar_wday.png",
                        "../PROJ_activeattack_graphics/output/univar_wday.png")
  copy_ifelse_checksums("www/univar_hr.png",
                        "../PROJ_activeattack_graphics/output/univar_hr.png")
  
  #attackers
  copy_ifelse_checksums("www/univar_race.png",
                        "../PROJ_activeattack_graphics/output/univar_race.png")
  copy_ifelse_checksums("www/univar_age.png",
                        "../PROJ_activeattack_graphics/output/univar_age.png")
  copy_ifelse_checksums("www/univar_weapon.png",
                        "../PROJ_activeattack_graphics/output/univar_weapon.png")
  
  #locations
  copy_ifelse_checksums("www/univar_loc.png",
                        "../PROJ_activeattack_graphics/output/univar_loc.png")
  copy_ifelse_checksums("www/univar_rel.png",
                        "../PROJ_activeattack_graphics/output/univar_rel.png")
  copy_ifelse_checksums("www/bivar_loctype_rel.png",
                        "../PROJ_activeattack_graphics/output/bivar_loctype_rel.png")
  copy_ifelse_checksums("www/bivar_loc_hr.png",
                        "../PROJ_activeattack_graphics/output/bivar_loc_hr.png")
  
  #fatalities
  copy_ifelse_checksums("www/bivar_eventkilled.png",
                        "../PROJ_activeattack_graphics/output/bivar_eventkilled.png")
  # copy_ifelse_checksums("www/bivar_kill_yr.png",
  #                       "../PROJ_activeattack_graphics/output/bivar_kill_yr.png")
  # copy_ifelse_checksums("www/bivar_kill_year.html",
  #                       "../PROJ_activeattack_graphics/output/bivar_kill_year.html")
  copy_ifelse_checksums("www/bivar_kill_weapon.png",
                        "../PROJ_activeattack_graphics/output/bivar_kill_weapon.png")
  copy_ifelse_checksums("www/bivar_kill_weapon.html",
                        "../PROJ_activeattack_graphics/output/bivar_kill_weapon.html")
  copy_ifelse_checksums("www/bivar_wound_kill.png",
                        "../PROJ_activeattack_graphics/output/bivar_wound_kill.png")
  copy_ifelse_checksums("www/bivar_wound_kill.html",
                        "../PROJ_activeattack_graphics/output/bivar_wound_kill.html")
  
  #geospatial
  copy_ifelse_checksums("www/rolling_map.gif",
                        "../PROJ_activeattack_graphics/output/rolling_map.gif")
  copy_ifelse_checksums("www/bicol_map_attackxkilled.png",
                        "../PROJ_activeattack_graphics/output/bicol_map_attackxkilled.png")
  #fact sheet: latest-year map (web tab and PDF)
  copy_ifelse_checksums("www/map_latest_year.svg",
                        "../PROJ_activeattack_graphics/output/map_latest_year.svg")
  copy_ifelse_checksums("www/bicol_map_attackxkilled.html",
                        "../PROJ_activeattack_graphics/output/bicol_map_attackxkilled.html")
}

update_aa_victim_scroll <- function() {
  if (Sys.getenv("AA_SKIP_UPDATE") == "1") {
    message("AA_SKIP_UPDATE=1: not refreshing from the feeder repos")
    return(invisible(NULL))
  }

  
  #victim scroll
  copy_ifelse_checksums("www/victim_scroll.mp4",
                        "../PROJ_activeattack_graphics/output/victim_scroll.mp4")
}

#names for the Remembrance page (committed to data/ so CI renders without DATA_aa)
update_aa_victims <- function(version) {
  if (Sys.getenv("AA_SKIP_UPDATE") == "1") {
    message("AA_SKIP_UPDATE=1: not refreshing from the feeder repos")
    return(invisible(NULL))
  }

  copy_ifelse_checksums(glue("data/victims_{version}.rds"),
                        glue("../DATA_aa/output/victims/victims_{version}.rds"))
}

#=function to format numbers inline============================================
format_num <- scales::label_comma(big.mark = ",")

#=function to get percentages of specific levels of a variable=================
get_pct <- function(data, var_name, value) {
  data |>
    mutate(target = {{ var_name }} %in% value) |> # Flag rows matching the value/range
    summarise(
      n_total = n(),
      n_target = sum(target),
      pct = round((n_target / n_total) * 100, 1)
    ) |>
    pull(pct)
}

#=function to get the mean of specific levels of a variable====================
get_mean <- function(data, var_name, value) {
  data |>
    filter({{ var_name }} %in% value) |> # Filter to relevant categories or ranges
    count({{ var_name }}) |> # Count rows per value
    summarise(mean_count = round(mean(n, na.rm = TRUE)), 1) |> # Calculate mean of those counts
    pull(mean_count)
}

#=function to get the raw counts of specific levels of a variable==============
get_count <- function(data, var_name, value) {
  data |>
    filter({{ var_name }} %in% value) |> # Filter based on your categories or ranges
    nrow() # Count the number of rows
}

#=function to get the raw counts of specific levels of a variable==============
get_total <- function(data, var_name) {
  data |>
    summarise(across({{ var_name }}, ~ sum(.x, na.rm = TRUE))) |>
    summarise(total = sum(across(everything()))) |>
    pull(total)
}

#function to collapse strings with the appropriate and after the last comma====
oxford_collapse <- function(strings) {
  n <- length(strings)
  
  if (n == 0) {
    return("")
  } else if (n == 1) {
    return(strings)
  } else if (n == 2) {
    return(paste(strings, collapse = ", and "))
  } else {
    return(paste(paste(strings[-n], collapse = ", "), ", and ", strings[n], sep = ""))
  }
}


