library(testthat)
library(fs)

# Create a temporary directory for testing
temp_dir <- tempdir()

# Create a toy dataset
toy_dataset <- function(dir_name) {
  dir_create(path(temp_dir, dir_name))
}

# Test cases
test_that("contains_r_folder works correctly", {
  # Case 1: Directory with 'R' folder
  toy_dataset("package_with_R")
  dir_create(path(temp_dir, "package_with_R", "R"))
  expect_true(contains_r_folder(path(temp_dir, "package_with_R")))
  
  # Case 2: Directory without 'R' folder
  toy_dataset("package_without_R")
  expect_false(contains_r_folder(path(temp_dir, "package_without_R")))
  
  # Clean up
  dir_delete(path(temp_dir, "package_with_R"))
  dir_delete(path(temp_dir, "package_without_R"))
})
