library(httr2)
library(dplyr)
library(lubridate)

#' Get Package Version Information
#'
#' Retrieves the version information of a specified R package by querying a REST API.
#' This function sends an HTTP POST request to the specified URL and expects a JSON response
#' containing the version details of the requested package. It returns the most recent versions
#' based on the 'last_num' parameter.
#'
#' @param package_name The name of the R package for which version information is requested.
#' @param last_num The number of most recent versions to return, default is 10.
#'
#' @return If successful, returns a tibble with columns `package_name`, `package_version`,
#' `link`, `date`, and `size` indicating the version details of the package. The results are sorted
#' by the most recent dates. If the specified package name does not exist in the response or if the
#' API call fails, the function may return NULL or an error message, depending on the API's response.
#'
#' @importFrom dplyr bind_rows arrange slice_head
#' @importFrom httr2 request req_body_json req_headers req_perform resp_body_json
#' @importFrom lubridate ymd_hm
#' @examples
#' # Example usage:
#' # Assuming the function and the API endpoint are properly set up and accessible:
#' get_package_version("ggplot2")
#' # Expected result:
#' # A tibble: 44 × 5
#' #   package_name    package_version link                 date             size 
#' #   <chr>           <chr>           <chr>                <chr>            <chr>
#' # 1 dplyr           0.1.1           dplyr_0.1.1.tar.gz   2014-01-29 21:24 530K 
#' # 2 dplyr           0.1.2           dplyr_0.1.2.tar.gz   2014-02-24 16:36 533K 
#' # 3 dplyr           0.1.3           dplyr_0.1.3.tar.gz   2014-03-15 00:36 535K 
#' # 4 dplyr           0.1             dplyr_0.1.tar.gz     2014-01-16 22:53 2.7M 
#' 
#' @export
get_package_version <- function(package_name, last_num = 10) {
  url <- "https://r-connect-dev.prod.p488440267176.aws-emea.sanofi.com/content/2bb1fda0-b2fb-4686-b613-310d5a74e453/get_all_package_version/"
  body <- list(package = package_name)
  
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
  
  # Parse the JSON content of the response
  base_response <- resp_body_json(response)
  
  # Check if the response contains versions
  if (!"version" %in% names(base_response) || length(base_response$version) == 0) {
    return(NULL)
  }
  
  # Process the response if it contains versions
  if ("version" %in% names(base_response)) {
    response_df <- dplyr::bind_rows(base_response$version)
    response_df$date <- lubridate::ymd_hm(response_df$date)
    response_df <- dplyr::arrange(response_df, dplyr::desc(date)) %>% 
      dplyr::slice_head(n = last_num)
  } 
  
  return(response_df)
}

