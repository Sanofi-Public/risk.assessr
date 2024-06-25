library(httr)
library(jsonlite)
library(dplyr)
library(httr2)
library(dplyr)
library(lubridate)

#' Get Bioconductor Package Version Information
#'
#' Retrieves the version information of a specified Bioconductor package by querying a REST API.
#' This function sends an HTTP POST request to the specified URL and expects a JSON response
#' containing the version details of the requested package.
#'
#' @param package_name The name of the Bioconductor package for which version information is requested.
#' @param version The specific version of the package you want information about.
#'
#' @return If successful, returns a list containing version details of the package. The structure
#' of the response depends on the API's response format. If the specified package name does not exist
#' in the response or if the API call fails, the function may return NULL or an error message,
#' depending on the API's response.
#'
#' @importFrom httr2 request req_body_json req_headers req_perform resp_body_json resp_status
#' @examples
#' \dontrun{
#' # Example usage:
#' package_info <- fetchBioconductorPackageInfo("GenomicRanges", "1.42.0")
#' print(package_info)
#' }
#' @export
fetchBioconductorPackageInfo <- function(package_name, version) {
  # Hypothetical URL to fetch package info
  url <- "https://r-connect-dev.prod.p488440267176.aws-emea.sanofi.com/content/2bb1fda0-b2fb-4686-b613-310d5a74e453/get_all_bioconductor_version/"
  
  # JSON body for the request
  body <- list(
    name = package_name,
    version = version
  )
  
  # Perform the request
  response <- request(url) %>%
    req_body_json(body) %>%
    req_headers(
      accept = "application/json",
      `Content-Type` = "application/json"
    ) %>% 
    req_perform()
  
  # Check for a successful status code
  if (resp_status(response) != 200) {
    stop("API request failed with status code: ", resp_status(response))
  }
  
  # Parse the JSON content of the response
  base_response <- resp_body_json(response)
  
  return(base_response)
}