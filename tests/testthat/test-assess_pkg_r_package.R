library(testthat)
library(sanofi.risk.metric)
library(httr2)
library(jsonlite)

test_that("assess_pkg_r_package handles non-existent packages gracefully", {
  
  result <- assess_pkg_r_package("thispackagedoesnotexist")
  # Check that an error message is returned for a non-existent package
  expect_true(!is.null(result$error))
})

test_that("test on fail url package not found", {
  
  # Mock function to simulate `req_perform`
  mock_req_perform_fail <- function(request) {
    # Define the response body as a list
    response_body <- list(
      package_name = "some_package",
      version = "1.02222.0",
      tar_link = NA,
      source = "CRAN",
      error = "Version 1.02222.0 for dplyr not found",
      version_available = c(
        "0.1.1", "0.1.2", "0.1.3", "0.1", "0.2", "0.3.0.1", "0.3.0.2", "0.3"
      )
    )
    
    # Convert the list to a JSON string
    response_json <- jsonlite::toJSON(response_body, auto_unbox = TRUE)
    
    # Create the response object using httr2
    base_response <- httr2::response(
      status_code = 200,
      url = "http://example.com",
      headers = list("Content-Type" = "application/json"),
      body = charToRaw(response_json)
    )
    
    # Return the response object
    return(base_response)
  }  
  # Mock the bindings
  local_mocked_bindings(req_perform = mock_req_perform_fail, .package = "httr2")
  
  # Test the result
  result <- assess_pkg_r_package("some_package")
  expect_type(result, "list")
  expect_identical(result$error, "Version 1.02222.0 for dplyr not found")
})

test_that("test on unvalid tar link", {
  
  # Mock function to simulate `req_perform`
  mock_req_perform_sucess <- function(request) {
    # Define the response body as a list
    response_body <- list(
      package_name = "ggplot2",
      version = "3.3.5",
      tar_link = "http://example.com/false_link",
      source = "CRAN",
      error = NA,
      version_available = c(
        "0.1.1", "0.1.2", "0.1.3", "0.1", "0.2", "0.3.0.1", "0.3.0.2", "0.3"
      )
    )
    
    # Convert the list to a JSON string
    response_json <- jsonlite::toJSON(response_body, auto_unbox = TRUE)
    
    # Create the response object using httr2
    base_response <- httr2::response(
      status_code = 200,
      url = "http://example.com",
      headers = list("Content-Type" = "application/json"),
      body = charToRaw(response_json)
    )
    
    # Return the response object
    return(base_response)
  }
  # Mock the bindings
  local_mocked_bindings(req_perform = mock_req_perform_sucess, .package = "httr2")
  
  # Test the result
  expect_error(assess_pkg_r_package("some_package"))
  expect_error(assess_pkg_r_package("some_package"), regexp = "Failed to download the package from the provided URL")
})
