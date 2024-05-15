library(testthat)
library(httr2)
library(dplyr)


# Write a test
test_that("get_package_version works as expected", {
  # Create a mock response
  body_reps <- list(
    version = list(
      list(version = "1.0.0", date = "2023-05-01 12:00"),
      list(version = "1.0.1", date = "2023-05-02 12:00")
    )
  )
  
  # Convert the mock response to the format expected by resp_body_json
  mock_response <- httr2::response$new(
    method = "POST",
    url = "https://example.com",
    status_code = 200,
    headers = list("Content-Type" = "application/json"),
    body = jsonlite::toJSON(body_reps, auto_unbox = TRUE)
  )
  
  # Mock the req_perform function
  mock_req_perform <- mockery::mock(mock_response)
  mockery::stub(get_package_version, 'req_perform', mock_req_perform)
  
  # Call the function
  result <- get_package_version("dummy_package")
  
  # Check the result
  expect_true("version" %in% names(result))
  expect_equal(nrow(result), 2)
  expect_equal(result$version[1], "1.0.1")
  expect_equal(result$version[2], "1.0.0")
})
