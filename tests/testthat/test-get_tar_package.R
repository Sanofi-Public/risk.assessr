library(testthat)
library(httr2)
library(dplyr)
library(jsonlite)

test_that("test on correct result", {
  # Mock function to simulate `req_perform`
  mock_req_perform <- function(request) {
    # Define the response body as a list
    response_body <- list(
      package_name = "ggplot2",
      version = "3.3.5",
      tar_link = "http://example.com/package/ggplot2_3.3.5.tar.gz",
      source = "CRAN",
      error = NA,
      version_available = c(
        "0.1.1", "0.1.2", "0.1.3", "0.1", "0.2", "0.3.0.1", "0.3.0.2", "0.3",
        "0.4.0", "0.4.1", "0.4.2", "0.4.3", "0.5.0", "0.7.0", "0.7.1", "0.7.2",
        "0.7.3", "0.7.4", "0.7.5", "0.7.6", "0.7.7", "0.7.8", "0.8.0.1", "0.8.0",
        "0.8.1", "0.8.2", "0.8.3", "0.8.4", "0.8.5", "1.0.0", "1.0.1", "1.0.2",
        "1.0.3", "1.0.4", "1.0.5", "1.0.6", "1.0.7", "1.0.8", "1.0.9", "1.0.10",
        "1.1.0", "1.1.1", "1.1.2", "1.1.3", "1.1.4"
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
  local_mocked_bindings(req_perform = mock_req_perform, .package = "httr2")
  
  # Test the result
  result <- get_tar_package("ggplot2", "3.3.5")
  expect_equal(result$package_name, "ggplot2")
  expect_equal(result$version, "3.3.5")
  expect_equal(result$tar_link, "http://example.com/package/ggplot2_3.3.5.tar.gz")
  expect_equal(result$source, "CRAN")
  expect_null(result$error)
  expect_true("1.0.0" %in% result$version_available)
})

test_that("test unsuccessful response", {
  # Mock function to simulate `req_perform`
  mock_req_perform <- function(request) {
    # Create the response object with a 404 status code
    base_response <- httr2::response(
      status_code = 404,
      url = "http://example.com",
      headers = list("Content-Type" = "application/json"),
      body = charToRaw('{"error": "Not Found"}')
    )
    
    # Return the response object
    return(base_response)
  }
  
  # Mock the bindings
  local_mocked_bindings(req_perform = mock_req_perform, .package = "httr2")
  
  # Test the result for an unsuccessful response
  expect_error(get_tar_package("dummy_package", "3"),
               "API request failed with status code: 404")
})

test_that("test version not found", {
  # Mock function to simulate `req_perform`
  mock_req_perform <- function(request) {
    # Define the response body as a list
    response_body <- list(
      package_name = "dplyr",
      version = "1.02222.0",
      tar_link = NA,
      source = "CRAN",
      error = "Version 1.02222.0 for dplyr not found",
      version_available = c(
        "0.1.1", "0.1.2", "0.1.3", "0.1", "0.2", "0.3.0.1", "0.3.0.2", "0.3",
        "0.4.0", "0.4.1", "0.4.2", "0.4.3", "0.5.0", "0.7.0", "0.7.1", "0.7.2",
        "0.7.3", "0.7.4", "0.7.5", "0.7.6", "0.7.7", "0.7.8", "0.8.0.1", "0.8.0",
        "0.8.1", "0.8.2", "0.8.3", "0.8.4", "0.8.5", "1.0.0", "1.0.1", "1.0.2",
        "1.0.3", "1.0.4", "1.0.5", "1.0.6", "1.0.7", "1.0.8", "1.0.9", "1.0.10",
        "1.1.0", "1.1.1", "1.1.2", "1.1.3", "1.1.4"
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
  local_mocked_bindings(req_perform = mock_req_perform, .package = "httr2")
  
  # Test the result for an unsuccessful response
  result <- get_tar_package("dplyr", "1.02222.0")
  expect_equal(result$package_name, "dplyr")
  expect_equal(result$version, "1.02222.0")
  expect_null(result$tar_link)
  expect_equal(result$source, "CRAN")
  expect_equal(result$error, "Version 1.02222.0 for dplyr not found")
  expect_true("1.0.0" %in% result$version_available)
})

test_that("test version is NULL", {
  # Mock function to simulate `req_perform`
  mock_req_perform <- function(request) {
    # Define the response body as a list
    response_body <- list(
      package_name = "ggplot2",
      version = "3.3.5",
      tar_link = "http://example.com/package/ggplot2_3.3.5.tar.gz",
      source = "CRAN",
      error = NA,
      version_available = c(
        "0.1.1", "0.1.2", "0.1.3", "0.1", "0.2", "0.3.0.1", "0.3.0.2", "0.3",
        "0.4.0", "0.4.1", "0.4.2", "0.4.3", "0.5.0", "0.7.0", "0.7.1", "0.7.2",
        "0.7.3", "0.7.4", "0.7.5", "0.7.6", "0.7.7", "0.7.8", "0.8.0.1", "0.8.0",
        "0.8.1", "0.8.2", "0.8.3", "0.8.4", "0.8.5", "1.0.0", "1.0.1", "1.0.2",
        "1.0.3", "1.0.4", "1.0.5", "1.0.6", "1.0.7", "1.0.8", "1.0.9", "1.0.10",
        "1.1.0", "1.1.1", "1.1.2", "1.1.3", "1.1.4"
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
  local_mocked_bindings(req_perform = mock_req_perform, .package = "httr2")
  
  # Test the result when version is NULL
  result <- get_tar_package("ggplot2", NULL)
  expect_equal(result$package_name, "ggplot2")
  expect_equal(result$version, "3.3.5")
  expect_equal(result$tar_link, "http://example.com/package/ggplot2_3.3.5.tar.gz")
  expect_equal(result$source, "CRAN")
  expect_null(result$error)
  expect_true("1.0.0" %in% result$version_available)
})

