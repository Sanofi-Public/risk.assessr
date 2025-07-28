#' Extract aria-label from SVG data
#'
#' Extracts the aria-label attribute value from SVG data badge.
#'
#' @param svg_data A character string containing SVG data.
#' @return A character string containing the extracted aria-label value, or NULL if not found.
#' @keywords internal
extract_aria_label <- function(svg_data) {
  match <- regmatches(svg_data, regexpr('aria-label="([^"]+)"', svg_data, perl = TRUE))
  
  if (length(match) > 0) {
    return(sub('aria-label="([^"]+)"', '\\1', match))
  }
  
  return(NULL)
}


#' Convert Abbreviated Numbers to Integers
#'
#' Converts a string containing a number with optional 'K' or 'M' abbreviation into an integer.
#'
#' @param value A character string representing a number (e.g., '1.2M', '500K', '100').
#' @return An integer representation of the numeric value.
#' @keywords internal
convert_abbreviation_to_number <- function(value) {
  
  match <- regexec("^([0-9]+\\.?[0-9]*)([KM]?)$", value, ignore.case = TRUE)
  parts <- regmatches(value, match)
  
  if (length(parts) == 0 || length(parts[[1]]) < 2) {
    return(as.numeric(value))
  }
  
  number <- as.numeric(parts[[1]][2])
  unit <- toupper(parts[[1]][3])
  
  if (unit == "K") {
    return(as.integer(number * 1e3))
  } else if (unit == "M") {
    return(as.integer(number * 1e6))
  }
  
  return(as.integer(number))
}

#' Get CRAN Package Download Count
#'
#' Retrieves the download count for a given CRAN package from the CRAN logs API.
#'
#' @param package_name A character string specifying the package name.
#' @param timeline A character string specifying the timeline ('last-month', or 'grand-total').
#' @return An integer representing the total number of downloads.
#' @examples
#' \dontrun{
#' total_download_result <- get_package_download('ggplot2')
#' 
#' month_download_result <- get_package_download('dplyr', 'last-month')
#' }
#' @export
get_package_download <- function(package_name, timeline = "grand-total") {
  # Construct the URL for the CRAN badge API
  url <- paste0("https://cranlogs.r-pkg.org/badges/", timeline, "/", package_name)
  
  # Initialize a curl handle
  handle <- curl::new_handle()
  
  # Fetch the response
  con <- curl::curl(url, handle = handle)
  svg_content <- readLines(con, warn = FALSE)
  close(con)
  
  # Combine lines in case the response spans multiple lines
  svg_text <- paste(svg_content, collapse = "\n")
  
  # Extract the aria-label text from the SVG
  text <- extract_aria_label(svg_text)
  
  if (!is.null(text)) {
    match <- regexec("CRAN downloads ([0-9.]+[KM]?)", text)
    parts <- regmatches(text, match)
    
    if (length(parts) > 0 && length(parts[[1]]) > 1) {
      return(convert_abbreviation_to_number(parts[[1]][2]))
    }
  }
  
  return(0)
}
