library(testthat)
library(httr2)
library(dplyr)
library(jsonlite)
#' Get TAR Package URL
#'
#' This function retrieves the URL of a TAR package given its name and version.
#'
#' @param package_name A character string specifying the name of the package.
#' @param version A character string specifying the version of the package.
#'
#' @return A list containing the response from the API, which includes the URL of the TAR package.
#'
#' @details This function sends a POST request to a specified API endpoint with the package name and version as the body. 
#' If the request is successful, the function returns the response from the API, which contains the URL of the TAR package.
#' If the request fails, the function stops and returns an error message with the status code.
#'
#' @importFrom httr2 request req_body_json req_headers req_perform resp_body_json resp_status
#' @importFrom jsonlite fromJSON
#' @export
#'
#' @examples
#' \dontrun{
#' result <- get_tar_package("dplyr", "1.0.0")
#' print(result)
#' # Expected output:
#'$package_name
#'[1] "dplyr"
#'
#'$version
#'[1] "1.0.0"
#'
#'$tar_link
#'[1] "https://cran.r-project.org/src/contrib/Archive/dplyr/dplyr_1.0.0.tar.gz"
#'
#'$source
#'[1] "CRAN"
#'
#'$error
#'NULL
#'
#'$version_available
#'[1] "0.1.1, 0.1.2, 0.1.3, 0.1, 0.2, 0.3.0.1, 0.3.0.2, 0.3, 0.4.0, 0.4.1, 
#'0.4.2, 0.4.3, 0.5.0, 0.7.0, 0.7.1, 0.7.2, 0.7.3, 0.7.4, 0.7.5, 0.7.6, 
#'0.7.7, 0.7.8, 0.8.0.1, 0.8.0, 0.8.1, 0.8.2, 0.8.3, 0.8.4, 0.8.5, 1.0.0, 
#'1.0.1, 1.0.2, 1.0.3, 1.0.4, 1.0.5, 1.0.6, 1.0.7, 1.0.8, 1.0.9, 1.0.10, 
#'1.1.0, 1.1.1, 1.1.2, 1.1.3, 1.1.4"
#' }
get_tar_package <- function(package_name, version=NA) {
  url <- "https://r-connect-dev.prod.p488440267176.aws-emea.sanofi.com/content/2bb1fda0-b2fb-4686-b613-310d5a74e453/tar-link"
  body <- list(
    repo_name = package_name,
    version = version
  )
  
  # Perform the request
  response <- httr2::request(url) %>%
    req_body_json(body) %>%
    req_headers(
      accept = "application/json",
      `Content-Type` = "application/json"
    ) %>%
    httr2::req_perform()
  
  # Check for a successful status code and print a success message
  if (resp_status(response) != 200) {
    stop("API request failed with status code: ", resp_status(response))
  }
  
  return(resp_body_json(response))
}
