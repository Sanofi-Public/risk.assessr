library(testthat)
library(httr2)
library(dplyr)
library(mockery)


# Test for correct result with two versions
test_that("test on correct result", {
  # Mock function to simulate `req_perform`
  mock_req_perform <- function(request) {
    structure(
      list(
        version = list(
          list(version = "1.0.0", date = "2023-05-01 12:00"),
          list(version = "1.0.1", date = "2023-05-02 12:00")
        )
      ),
      class = "httr2_response"
    )
  }
  
  # Mock the bindings
  local_mocked_bindings(
    req_perform = mock_req_perform,
    resp_body_json = function(response) response
  )
  
  # Test the result
  result <- get_package_version("dummy_package")
  expect_equal(nrow(result), 2)
  expect_equal(result$version, c("1.0.1", "1.0.0"))
  expect_equal(as.character(result$date), c("2023-05-02 12:00:00", "2023-05-01 12:00:00"))
})

# Test for correct result with more than 10 versions
test_that("test on correct result over 10 versions", {
  # Mock function to simulate `req_perform`
  mock_req_perform <- function(request) {
    structure(
      list(
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
      ),
      class = "httr2_response"
    )
  }
  
  # Mock the bindings
  local_mocked_bindings(
    req_perform = mock_req_perform,
    resp_body_json = function(response) response
  )
  
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

# Test for empty list response
test_that("test empty list response", {
  # Mock function to simulate `req_perform`
  mock_req_perform <- function(request) {
    structure(
      list(
        version = list()
      ),
      class = "httr2_response"
    )
  }
  
  # Mock the bindings
  local_mocked_bindings(
    req_perform = mock_req_perform,
    resp_body_json = function(response) response
  )
  
  # Test the result for an empty list response
  result <- get_package_version("dummy_package")
  expect_equal(result, NULL)
})

