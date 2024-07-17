library(testthat)
library(httr2)
library(dplyr)
library(jsonlite)

test_that("test on correct result", {
  # Mock function to simulate `req_perform`
  mock_req_perform <- function(request) {
    # Define the response body as a list
    response_body <- list(
      Version = "1.24.0",
      `In Bioconductor since` = "BioC 2.12 (R-3.0) (11 years)",
      License = "LGPL (>= 3)",
      Depends = "S4Vectors(>= 0.9.25),IRanges,GenomicRanges,SummarizedExperiment(>= 1.1.6)",
      URL = "https://github.com/mikelove/DESeq2",
      `Source Package` = "https://bioconductor.org/packages/3.9/bioc/src/contrib/DESeq2_1.24.0.tar.gz",
      `package url` = "https://bioconductor.org/packages/3.9/bioc/html/DESeq2.html",
      `Bioconductor Version` = "3.9",
      `R Version` = "3.6",
      `package name` = "DESeq2"
    )
    
    # Convert the list to a JSON string
    response_json <- jsonlite::toJSON(response_body, auto_unbox = TRUE)
    
    # Create the response object using httr2
    base_response <- response(
      status_code = 200,
      url = "http://example.com",
      headers = list("Content-Type" = "application/json"),
      body = charToRaw(response_json)
    )
    
    # Return the response object
    return(base_response)
  }
  
  # Mock the bindings
  local_mocked_bindings(req_perform = mock_req_perform)
  
  # Test the result
  package_info <- fetch_Bioconductor_Package_Info("DESeq2", "1.24.0")
  expect_equal(package_info$Version, "1.24.0")
})

test_that("test on missing package", {
  # Mock function to simulate `req_perform`
  mock_req_perform <- function(request) {
    # Define the response body as an error message
    response_body <- list(
      error = "Package not found"
    )
    
    # Convert the list to a JSON string
    response_json <- jsonlite::toJSON(response_body, auto_unbox = TRUE)
    
    # Create the response object using httr2
    base_response <- response(
      status_code = 404,
      url = "http://example.com",
      headers = list("Content-Type" = "application/json"),
      body = charToRaw(response_json)
    )
    
    # Return the response object
    return(base_response)
  }
  
  # Mock the bindings
  local_mocked_bindings(req_perform = mock_req_perform)
  # Test the result
  expect_error(fetch_Bioconductor_Package_Info("NonExistentPackage", "1.0.0"), 
               "API request failed with status code: 404")
})

test_that("test on incorrect version", {
  # Mock function to simulate `req_perform`
  mock_req_perform <- function(request) {
    # Define the response body as an error message
    response_body <- list(
      error = "Version not found"
    )
    
    # Convert the list to a JSON string
    response_json <- jsonlite::toJSON(response_body, auto_unbox = TRUE)
    
    # Create the response object using httr2
    base_response <- response(
      status_code = 404,
      url = "http://example.com",
      headers = list("Content-Type" = "application/json"),
      body = charToRaw(response_json)
    )
    
    # Return the response object
    return(base_response)
  }
  
  # Mock the bindings
  local_mocked_bindings(req_perform = mock_req_perform)
  # Test the result
  expect_error(fetch_Bioconductor_Package_Info("DESeq2", "0.0.0"), 
               "API request failed with status code: 404")
})

test_that("test on empty response", {
  # Mock function to simulate `req_perform`
  mock_req_perform <- function(request) {
    # Define the response body as an empty list
    response_body <- list()
    
    # Convert the list to a JSON string
    response_json <- jsonlite::toJSON(response_body, auto_unbox = TRUE)
    
    # Create the response object using httr2
    base_response <- response(
      status_code = 200,
      url = "http://example.com",
      headers = list("Content-Type" = "application/json"),
      body = charToRaw(response_json)
    )
    
    # Return the response object
    return(base_response)
  }
  
  # Mock the bindings
  local_mocked_bindings(req_perform = mock_req_perform)
  # Test the result
  package_info <- fetch_Bioconductor_Package_Info("nonexistingpackage", "1.24.0")
  expect_true(length(package_info) == 0)
})

test_that("test on internal server error", {
  # Mock function to simulate `req_perform`
  mock_req_perform <- function(request) {
    # Create the response object using httr2
    base_response <- response(
      status_code = 500,
      url = "http://example.com",
      headers = list("Content-Type" = "application/json"),
      body = charToRaw("{}")
    )
    
    # Return the response object
    return(base_response)
  }
  
  # Mock the bindings
  local_mocked_bindings(req_perform = mock_req_perform)
  # Test the result
  expect_error(fetch_Bioconductor_Package_Info("DESeq2", "1.24.0"), 
               "API request failed with status code: 500")
})

test_that("test on unexpected content type", {
  # Mock function to simulate `req_perform`
  mock_req_perform <- function(request) {
    # Define the response body as plain text
    response_body <- "Unexpected content"
    
    # Create the response object using httr2
    base_response <- response(
      status_code = 200,
      url = "http://example.com",
      headers = list("Content-Type" = "text/plain"),
      body = charToRaw(response_body)
    )
    
    # Return the response object
    return(base_response)
  }
  
  # Mock the bindings
  local_mocked_bindings(req_perform = mock_req_perform)
  # Test the result
  expect_error(fetch_Bioconductor_Package_Info("DESeq2", "1.24.0"))
})


