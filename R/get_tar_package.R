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
#' 
#' # result <- get_tar_package("dplyr", "1.0.0")
#' # print(result)
#' # Expected output:
#' # $url
#' # [1] "https://cran.r-project.org/src/contrib/Archive/dplyr/dplyr_1.0.0.tar.gz"
get_tar_package <- function(package_name, version) {
  url <- "https://r-connect-dev.prod.p488440267176.aws-emea.sanofi.com/content/2bb1fda0-b2fb-4686-b613-310d5a74e453/get_tar_link/"
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
  
  # Check for a successful status code and print a success message
  if (resp_status(response) != 200) {
    stop("API request failed with status code: ", resp_status(response))
  }
  
  return(resp_body_json(response))
}
