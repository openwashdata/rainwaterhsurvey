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
# Load the necessary data from a CSV file
data_in <- readr::read_csv("data-raw/Rainwater Harvesting and Groundwater Recharge Household Survey.csv")

# (Optional) Read and clean the codebook if needed (commented out for now)
# codebook <- readxl::read_excel("data-raw/codebook.xlsx") %>%
#   clean_names()

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

rainwaterharvesting <- data_in

# Export Data ------------------------------------------------------------------
usethis::use_data(rainwaterharvesting, overwrite = TRUE)
fs::dir_create(here::here("inst", "extdata"))
readr::write_csv(rainwaterharvesting,
                 here::here("inst", "extdata", paste0("rainwaterharvesting", ".csv")))
openxlsx::write.xlsx(rainwaterharvesting,
                     here::here("inst", "extdata", paste0("rainwaterharvesting",
                                                          ".xlsx")))
