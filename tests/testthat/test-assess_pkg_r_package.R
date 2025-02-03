test_that("test on invalid package name", {
  
  mock_download_version_error <- function(package, version = NA, ...) {
    stop(paste0("Failed to download the package '", package, "' using remotes::download_version."))
  }
  
  # Apply mocked binding for remotes::download_version
  local_mocked_bindings(
    download_version = mock_download_version_error,
    .package = "remotes"
  )
  
  # Expect an error with a specific message for the invalid tar link
  expect_error(
    assess_pkg_r_package("some_package", "1.0.1"),
    regexp = "Failed to download the package 'some_package' using remotes::download_version."
  )
  
})

test_that("test on invalid package version", {
  # Mock remotes::download_version to simulate an invalid version error
  mock_download_version_error <- function(package, version = NA, ...) {
    stop(paste0("version '", version, "' is invalid for package '", package, "'"))
  }
  
  # Apply mocked binding for remotes::download_version
  local_mocked_bindings(
    download_version = mock_download_version_error,
    .package = "remotes"
  )
  
  # Expect an error with a specific message for the invalid version
  expect_error(
    assess_pkg_r_package("ggplot2", "10.0.1.8"),
    regexp = "version '10.0.1.8' is invalid for package 'ggplot2'"
  )
  
})