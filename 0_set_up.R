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

  #every figure the site shows, light at www/<file> and dark at www/dark/<file>
  #(graphics renders the dark twins with AA_MODE=dark into output/dark/)
  figs <- c(
    #timing
    "univar_yr.png", "univar_month.png", "univar_wday.png", "univar_hr.png",
    #attackers
    "univar_race.png", "univar_age.png", "univar_weapon.png",
    #locations
    "univar_loc.png", "univar_rel.png", "bivar_loctype_rel.png", "bivar_loc_hr.png",
    #casualties
    "bivar_eventkilled.png", "bivar_kill_weapon.png", "bivar_kill_weapon.html",
    "bivar_wound_kill.png", "bivar_wound_kill.html",
    #geospatial
    "rolling_map.gif", "bicol_map_attackxkilled.png", "bicol_map_attackxkilled.html",
    #fact sheet / home: latest-year map
    "map_latest_year.svg")
  dir.create("www/dark", showWarnings = FALSE)
  for (f in figs) {
    copy_ifelse_checksums(file.path("www", f), file.path("../PROJ_activeattack_graphics/output", f))
    dark <- file.path("../PROJ_activeattack_graphics/output/dark", f)
    if (file.exists(dark)) copy_ifelse_checksums(file.path("www/dark", f), dark)
    else warning("No dark twin for ", f, call. = FALSE)
  }
}

update_aa_victim_scroll <- function() {
  if (Sys.getenv("AA_SKIP_UPDATE") == "1") {
    message("AA_SKIP_UPDATE=1: not refreshing from the feeder repos")
    return(invisible(NULL))
  }

  
  #victim scroll and its poster (the title card, for the in-page player)
  copy_ifelse_checksums("www/victim_scroll.mp4",
                        "../PROJ_activeattack_graphics/output/victim_scroll.mp4")
  copy_ifelse_checksums("www/victim_scroll_poster.png",
                        "../PROJ_activeattack_graphics/output/preview/scroll_title.png")
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

#related datasets for the More Data page (datasets.qmd), committed to data/derived/
#so CI renders without the shared research drive. Their source of truth is Hunter's
#build on the drive (data/raw_data/k12_door_security, data/raw_data/officer_shot).
#Set AA_RESEARCH_DRIVE to the "Martaindale, Hunter - Research" folder; on a Mac
#with the library synced it is found without it.
derived_files <- c(
  k12_events   = "k12_door_security/k12_door_security_events_v2025.csv",
  k12_doors    = "k12_door_security/k12_door_security_doors_v2025.csv",
  k12_codebook = "k12_door_security/k12_door_security_codebook_v2025.pdf",
  ofc_data     = "officer_shot/officer_shot_data_v2025.csv",
  ofc_codebook = "officer_shot/officer_shot_codebook_v2025.pdf")

find_research_drive <- function() {
  root <- Sys.getenv("AA_RESEARCH_DRIVE")
  if (!nzchar(root)) {
    hits <- Sys.glob(file.path(path.expand("~"), "Library", "CloudStorage",
                               "OneDrive-SharedLibraries-*", "Martaindale*Research"))
    root <- if (length(hits)) hits[1] else ""
  }
  if (nzchar(root) && dir.exists(file.path(root, "data", "raw_data"))) root else NA_character_
}

update_derived_data <- function() {
  if (Sys.getenv("AA_SKIP_UPDATE") == "1" || Sys.getenv("GITHUB_ACTIONS") == "true") {
    return(invisible(NULL))
  }
  root <- find_research_drive()
  if (is.na(root)) {
    message("Research drive not found (set AA_RESEARCH_DRIVE): using the committed data/derived/ copies")
    return(invisible(NULL))
  }
  dir.create("data/derived", showWarnings = FALSE)
  for (f in derived_files) {
    copy_ifelse_checksums(file.path("data/derived", basename(f)), file.path(root, "data", "raw_data", f))
  }
  # page-1 thumbnail of each codebook for its download panel, as for the fact sheet
  # (poppler's pdftoppm); remade when the PDF is newer than its thumbnail
  for (f in grep("\\.pdf$", derived_files, value = TRUE)) {
    pdf   <- file.path("data/derived", basename(f))
    thumb <- file.path("www", sub("\\.pdf$", "_preview", basename(f)))
    if (!file.exists(paste0(thumb, ".png")) || file.mtime(pdf) > file.mtime(paste0(thumb, ".png"))) {
      res <- system2("pdftoppm", c("-png", "-r", "40", "-f", "1", "-l", "1", "-singlefile", pdf, thumb),
                     stdout = TRUE, stderr = TRUE)
      if (!is.null(attr(res, "status"))) warning("Codebook preview not made: ", paste(res, collapse = " "))
    }
  }
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
      pct_raw = (n_target / n_total) * 100,
      pct = round(pct_raw, 1)
    ) |>
    (\(x) structure(x$pct, raw = x$pct_raw))()
}

#=tile text from a get_pct() result, rounded once from the unrounded value========
#(rounding the 1-decimal value again turned 65.46 into 65.5 and then 66)
tile_pct <- function(p) paste0(round(attr(p, "raw")), "%")

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


