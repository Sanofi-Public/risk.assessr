library(testthat)
library(httr2)
library(dplyr)
library(mockery)
library(jsonlite)


test_that("test on correct result", {
  # Mock function to simulate `req_perform`
  mock_req_perform <- function(request) {
    # Define the response body as a list
    response_body <- 'http://example.com/package/ggplot2_3.3.5.tar.gz'
    
    # Convert the list to a JSON string
    response_json <- toJSON(response_body, auto_unbox = TRUE)
    
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
  local_mocked_bindings(req_perform = mock_req_perform)
  
  # Test the result
  result <- get_tar_package("ggplot2", "3.3.5")
  expect_equal(result, "http://example.com/package/ggplot2_3.3.5.tar.gz")
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
  local_mocked_bindings(req_perform = mock_req_perform)
  
  # Test the result for an unsuccessful response
  expect_error(get_tar_package("dummy_package", "3"),
               "API request failed with status code: 404")
})


test_that("test version not found", {
  # Mock function to simulate `req_perform`
  mock_req_perform <- function(request) {
    # Define the response body as a list
    response_body = structure(
      list(
        message = "Package name or version not found for ggplot2 package version 3.3.eeeeeeeee5."
      )
    )
    
    # Convert the list to a JSON string
    response_json <- toJSON(response_body, auto_unbox = TRUE)
    
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
  local_mocked_bindings(req_perform = mock_req_perform)
  result <- get_tar_package("ggplot2", "3.3.eeeeeeeee5")
  # Test the result for an unsuccessful response
  expect_equal(result$message, "Package name or version not found for ggplot2 package version 3.3.eeeeeeeee5.")
  
})
