library(testthat)
library(httr2)
library(dplyr)
library(jsonlite)

test_that("test on correct result", {
  #Mock function to simulate `req_perform`
    mock_req_perform <- function(request) {
      # Define the response body as a list
      response_body <- list(
        version = list(
          list(version = "1.0.0", date = "2023-05-01 12:00"),
          list(version = "1.0.1", date = "2023-05-02 12:00")
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
  testthat::local_mocked_bindings(req_perform = mock_req_perform)
  
  # Test the result
  result <- get_package_version("dummy_package")
  expect_equal(nrow(result), 2)
  expect_equal(result$version, c("1.0.1", "1.0.0"))
  expect_equal(as.character(result$date), c("2023-05-02 12:00:00", "2023-05-01 12:00:00"))
})


test_that("test on correct result over 10 versions", {
  # Mock function to simulate `req_perform`
  mock_req_perform <- function(request) {
    # Define the response body as a list
    response_body <- list(
      version = list(
        list(version = "1.0.0", date = "2023-05-01 12:00"),
        list(version = "1.0.1", date = "2023-05-02 12:00"),
        list(version = "1.0.0", date = "2023-05-01 12:00"),
        list(version = "1.0.1", date = "2023-05-02 12:00"),
        list(version = "1.0.0", date = "2023-05-01 12:00"),
        list(version = "1.0.1", date = "2023-05-02 12:00"),
        list(version = "1.0.0", date = "2023-05-01 12:00"),
        list(version = "1.0.1", date = "2023-05-02 12:00"),
        list(version = "1.0.0", date = "2023-05-01 12:00"),
        list(version = "1.0.1", date = "2023-05-02 12:00"),
        list(version = "1.0.0", date = "2023-05-01 12:00"),
        list(version = "1.0.1", date = "2023-05-02 12:00")
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

  testthat::local_mocked_bindings(req_perform = mock_req_perform)

  # Test the result for top 10 versions
  result_top_ten <- get_package_version("dummy_package")
  expect_equal(nrow(result_top_ten), 10)

  # Test the result for top 6 versions
  result_top_six <- get_package_version("dummy_package", 6)
  expect_equal(nrow(result_top_six), 6)

  # Test the result for more versions than available
  result_over_length <- get_package_version("dummy_package", 100)
  expect_equal(nrow(result_over_length), 12)
})

test_that("test empty list response", {
  # Mock function to simulate `req_perform`
  mock_req_perform <- function(request) {
    response_body <- list(
      version = list()
    )
    response_json <- jsonlite::toJSON(response_body, auto_unbox = TRUE)
    
    base_response <- httr2::response(
      status_code = 200,
      url = "http://example.com",
      headers = list("Content-Type" = "application/json"),
      body = charToRaw(response_json)
    )
    return(base_response)
  }
  
  # Mock the bindings
  testthat::local_mocked_bindings(req_perform = mock_req_perform)
  
  # Test the result for an empty list response
  result <- get_package_version("dummy_package")
  expect_equal(result, NULL)
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
  testthat::local_mocked_bindings(req_perform = mock_req_perform)

  # Test the result for an unsuccessful response
  expect_error(get_package_version("dummy_package"),
               "API request failed with status code: 404")
})

