# Description ------------------------------------------------------------------
# R script to process uploaded raw data into a tidy, analysis-ready data frame
# Load packages ----------------------------------------------------------------
## Run the following code in console if you don't have the packages
## install.packages(c("usethis", "fs", "here", "readr", "readxl", "openxlsx"))
library(usethis)
library(fs)
library(here)
library(readr)
library(dplyr)
library(readxl)
library(openxlsx)
library(lubridate)
library(ggplot2)
library(maps)


# Load Data --------------------------------------------------------------------
data_in <- readr::read_csv("data-raw/Rainwater Harvesting and Groundwater Recharge Household Survey.csv")

# Tidy data --------------------------------------------------------------------

# Function to check for non-UTF-8 characters in character columns
check_utf8 <- function(df) {
  # Identify columns with invalid UTF-8 characters
  invalid_cols <- sapply(df, function(column) {
    if (!is.character(column)) return(FALSE) # Skip non-character columns
    any(sapply(column, function(x) {
      if (is.na(x)) return(FALSE) # Ignore NA values
      !identical(iconv(x, from = "UTF-8", to = "UTF-8"), x)
    }))
  })

  # Extract the column names with invalid characters
  bad_cols <- names(df)[invalid_cols]

  # Output a message depending on whether non-UTF-8 characters were found
  if (length(bad_cols) > 0) {
    message("Non-UTF-8 characters detected in columns: ",
            paste(bad_cols, collapse = ", "))
  } else {
    message("No non-UTF-8 characters found.")
  }
}

# Convert character columns from Latin1 encoding to UTF-8, removing problematic
#   characters
data_in[] <- lapply(data_in, function(x) {
  if (is.character(x)) {
    # Convert to UTF-8 and remove problematic characters
    iconv(x, from = "latin1", to = "UTF-8", sub = "")
  } else {
    x
  }
})

# Re-check the data for non-UTF-8 characters after the conversion
check_utf8(data_in)

rainwaterhsurvey <- data_in

# Export Data ------------------------------------------------------------------
usethis::use_data(rainwaterhsurvey, overwrite = TRUE)
fs::dir_create(here::here("inst", "extdata"))
readr::write_csv(rainwaterhsurvey,
                 here::here("inst", "extdata", paste0("rainwaterhsurvey", ".csv")))
openxlsx::write.xlsx(rainwaterhsurvey,
                     here::here("inst", "extdata", paste0("rainwaterhsurvey",
                                                          ".xlsx")))
