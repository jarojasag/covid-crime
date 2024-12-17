library(tidyverse)
library(readxl)
library(lubridate)
library(stringi)

# Functions -------------------------------------------------------

#' Change Column Names
#' 
#' Updates the column names of a data frame with new names provided.
#' 
#' @param df A data frame whose column names need to be updated.
#' @param new_names A vector of new column names.
#' @return A data frame with updated column names.
change_col_names <- function(df, new_names) {
  colnames(df) <- new_names
  df
}

#' Clean and Format Column Names
#' 
#' Cleans column names by converting to lowercase, removing accents, 
#' and replacing spaces with underscores.
#' 
#' @param cols A vector of column names to be cleaned.
#' @return A vector of cleaned column names.
get_names <- function(cols) {
  cols %>%
    str_to_lower() %>%
    stri_trans_general("Latin-ASCII") %>%
    str_replace_all(" ", "_")
}

#' Read and Process Crime Files
#' 
#' Reads multiple Excel files, applies column name changes, and filters rows with missing `municipio`.
#' 
#' @param file_paths A vector of file paths to Excel files.
#' @param skip_cells The number of rows to skip when reading each file.
#' @param new_names A vector of new column names to assign.
#' @param col_type A vector specifying column types for reading.
#' @param col_range A character vector specifying the range of columns (e.g., "A:T").
#' @return A combined tibble containing all processed data.
read_crime_files <- function(file_paths, skip_cells, new_names, col_type, col_range) {
  map(file_paths, ~ {
    df <- read_excel(.x, skip = skip_cells, col_types = col_type, range = cell_cols(col_range))
    df <- change_col_names(df, new_names)
    initial_rows <- nrow(df)
    
    df_filtered <- filter(df, !is.na(municipio))
    dropped_rows <- initial_rows - nrow(df_filtered)
    
    cat("File:", .x, "- Dropped", dropped_rows, "rows (", 
        round(100 * dropped_rows / initial_rows, 2), "% of data) due to missing 'municipio'.\n")
    
    df_filtered
  }) %>% 
    bind_rows()
}

#' Write DataFrames to CSV
#' 
#' Writes a list of data frames to individual CSV files with specified names.
#' 
#' @param data_list A named list of data frames.
#' @param folder The folder path where CSV files will be saved.
#' @return None (side-effect: CSV files are saved).
write_historic_data <- function(data_list, folder) {
  walk2(data_list, names(data_list), ~ write_csv(.x, paste0(folder, "/", .y, ".csv")))
}

#' Count Events in Crime Data
#' 
#' Groups data by `departamento`, `municipio`, `barrio`, and `fecha`, 
#' and counts the number of rows per group.
#' 
#' @param crime_list A list of data frames containing crime data.
#' @return A list of summarized tibbles with counts of events.
count_crimes <- function(crime_list) {
  map(crime_list, ~ {
    initial_rows <- nrow(.x)
    grouped <- .x %>%
      group_by(departamento, municipio, barrio, fecha) %>%
      count()
    cat("Grouped data - Rows reduced from", initial_rows, "to", nrow(grouped), 
        "(", round(100 * (initial_rows - nrow(grouped)) / initial_rows, 2), "%).\n")
    grouped
  })
}

#' Process Crime Data Using Regex
#' 
#' Filters and combines crime data frames that match specified regex patterns.
#' 
#' @param crime_list A list of crime data frames.
#' @param regex_patterns A character vector of regex patterns to filter data.
#' @return A list of combined tibbles grouped by regex matches.
process_crime_data <- function(crime_list, regex_patterns) {
  map(regex_patterns, function(crime) {
    crime_name <- names(crime_list)[str_detect(names(crime_list), crime)]
    combined <- bind_rows(map(crime_list[crime_name], ~ .x))
    cat("Processing crime:", crime, "- Combined data has", nrow(combined), "rows.\n")
    combined
  })
}

#' Process Bogotá Crime Data
#' 
#' Filters, aggregates, and reshapes crime data for Bogotá, ensuring proper formatting.
#' 
#' @param crime_list A list of tibbles containing crime data.
#' @return A list of tibbles processed for Bogotá-specific analysis.
bogota_processing <- function(crime_list) {
  map(crime_list, ~ {
    initial_rows <- nrow(.x)  # Capture initial row count
    
    # Filter rows containing "BOGO" in `municipio`
    filtered_data <- .x %>% filter(str_detect(municipio, "BOGO"))
    dropped_rows_bogo <- initial_rows - nrow(filtered_data)
    
    cat("Filtering 'BOGO': Dropped", dropped_rows_bogo, 
        "rows (", round(100 * dropped_rows_bogo / initial_rows, 2), "% of data).\n")
    
    filtered_data %>%
      ungroup() %>%
      pivot_wider(names_from = barrio, values_from = n) %>%
      replace_na(list(n = 0)) %>%
      mutate(Año = year(fecha), Semana = week(fecha)) %>%
      pivot_longer(!c(fecha, Año, Semana), names_to = "Barrio", values_to = "n") %>%
      group_by(Año, Semana, Barrio) %>%
      summarise(n = sum(n), .groups = "drop") %>%
      separate(Barrio, c("barrio", "cod_localidad"), sep = " E-") %>%
      filter(!str_detect(barrio, ".*-")) %>%
      { 
        final_rows <- nrow(.)
        dropped_rows_clean <- nrow(filtered_data) - final_rows
        cat("Cleaning barrios: Dropped", dropped_rows_clean, 
            "rows (", round(100 * dropped_rows_clean / nrow(filtered_data), 2), "% of filtered data).\n")
        .
      }
  })
}
