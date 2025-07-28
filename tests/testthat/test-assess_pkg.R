test_that("running assess_pkg for test package in tar file - no notes", {
  skip_on_cran()
  r = getOption("repos")
  r["CRAN"] = "http://cran.us.r-project.org"
  options(repos = r)

  dp <- system.file("test-data", "test.package.0001_0.1.0.tar.gz",
                    package = "risk.assessr")

  # Mock get_host_package to return a fixed response
  mock_get_host_package <- function(pkg_name, pkg_ver, pkg_source_path) {
    return(list(cran_links = "CRAN", github_links = "No GitHub link found"))
  }
  
  # Apply mocked binding for risk.assessr::get_host_package
  local_mocked_bindings(
    get_host_package = mock_get_host_package,
    .package = "risk.assessr"
  )
  
  
  # set up package
  install_list <- set_up_pkg(dp)

  build_vignettes <- install_list$build_vignettes
  package_installed <- install_list$package_installed
  pkg_source_path <- install_list$pkg_source_path
  rcmdcheck_args <- install_list$rcmdcheck_args

  # install package locally to ensure test works
  package_installed <- install_package_local(pkg_source_path)
  package_installed <- TRUE

  if (package_installed == TRUE ) {

    rcmdcheck_args$path <- pkg_source_path
    assess_package <-assess_pkg(pkg_source_path, rcmdcheck_args)

    testthat::expect_identical(length(assess_package), 4L)

    testthat::expect_true(checkmate::check_class(assess_package, "list"))

    testthat::expect_identical(length(assess_package$results), 38L)

    testthat::expect_true(!is.na(assess_package$results$pkg_name))

    testthat::expect_true(!is.na(assess_package$results$pkg_version))

    testthat::expect_true(!is.na(assess_package$results$pkg_source_path))

    testthat::expect_true(!is.na(assess_package$results$date_time))

    testthat::expect_true(!is.na(assess_package$results$executor))

    testthat::expect_true(!is.na(assess_package$results$sysname))

    testthat::expect_true(!is.na(assess_package$results$version))

    testthat::expect_true(!is.na(assess_package$results$release))

    testthat::expect_true(!is.na(assess_package$results$machine))

    testthat::expect_true(!is.na(assess_package$results$comments))

    testthat::expect_true(!is.na(assess_package$results$has_bug_reports_url))

    testthat::expect_true(checkmate::test_numeric(assess_package$results$has_bug_reports_url))

    testthat::expect_true(!is.na(assess_package$results$license))

    testthat::expect_true(checkmate::test_numeric(assess_package$results$license))

    testthat::expect_true(!is.na(assess_package$results$size_codebase))

    testthat::expect_true(checkmate::test_numeric(assess_package$results$size_codebase))

    testthat::expect_true(checkmate::test_numeric(assess_package$results$check))

    testthat::expect_gte(assess_package$results$check, 0)

    testthat::expect_true(checkmate::test_numeric(assess_package$results$covr))

    testthat::expect_gte(assess_package$results$covr, 0.7)

    testthat::expect_true(checkmate::test_numeric(assess_package$results$dep_score))

    testthat::expect_true(checkmate::test_numeric(assess_package$results$overall_risk_score))

    testthat::expect_true(!is.na(assess_package$results$risk_profile))

    testthat::expect_identical(length(assess_package$covr_list), 2L)

    testthat::expect_true(!is.na(assess_package$covr_list$res_cov$name))

    testthat::expect_identical(length(assess_package$covr_list$res_cov$coverage), 2L)

    testthat::expect_identical(length(assess_package$tm), 6L)

    testthat::expect_true(!is.na(assess_package$tm$exported_function))

    testthat::expect_true(!is.na(assess_package$tm$code_script))

    testthat::expect_true(!is.na(assess_package$tm$documentation))

    testthat::expect_true(!is.na(assess_package$tm$description))

    testthat::expect_true(!is.na(assess_package$tm$coverage_percent))

    testthat::expect_identical(length(assess_package$check_list), 2L)

    testthat::expect_identical(length(assess_package$check_list$res_check), 21L)

    testthat::expect_true(!is.na(assess_package$check_list$res_check$platform))

    testthat::expect_true(!is.na(assess_package$check_list$res_check$package))

    testthat::expect_identical(length(assess_package$check_list$res_check$test_output), 1L)

    testthat::expect_true(!is.na(assess_package$check_list$res_check$test_output$testthat))

    testthat::expect_true(all(sapply(assess_package$check_list$res_check$session_info$platform, 
                                     function(x) !is.null(x) && x != "")))

  }
})


Sys.setenv("R_TESTS" = "") 
library(testthat)

test_that("running assess_pkg for test package in tar file - no exports", {
  skip_on_cran()
  r = getOption("repos")
  r["CRAN"] = "http://cran.us.r-project.org"
  options(repos = r)

  dp <- system.file("test-data", "test.package.0005_0.1.0.tar.gz",
                    package = "risk.assessr")

  # Mock get_host_package to return a fixed response
  mock_get_host_package <- function(pkg_name, pkg_ver, pkg_source_path) {
    return(list(cran_links = "CRAN", github_links = "No GitHub link found"))
  }
  
  # Apply mocked binding for risk.assessr::get_host_package
  local_mocked_bindings(
    get_host_package = mock_get_host_package,
    .package = "risk.assessr"
  )
  
  # set up package
  install_list <- set_up_pkg(dp)

  build_vignettes <- install_list$build_vignettes
  package_installed <- install_list$package_installed
  pkg_source_path <- install_list$pkg_source_path
  rcmdcheck_args <- install_list$rcmdcheck_args

  # install package locally to ensure test works
  package_installed <- install_package_local(pkg_source_path)
  package_installed <- TRUE

  if (package_installed == TRUE ) {

    # ensure path is set to package source path
    rcmdcheck_args$path <- pkg_source_path
    assess_package <- assess_pkg(pkg_source_path, rcmdcheck_args)

    testthat::expect_identical(length(assess_package), 4L)

    testthat::expect_true(checkmate::check_class(assess_package, "list"))

    testthat::expect_identical(length(assess_package$results), 38L)

    testthat::expect_true(!is.na(assess_package$results$pkg_name))

    testthat::expect_true(!is.na(assess_package$results$pkg_version))

    testthat::expect_true(!is.na(assess_package$results$pkg_source_path))

    testthat::expect_true(!is.na(assess_package$results$date_time))

    testthat::expect_true(!is.na(assess_package$results$executor))

    testthat::expect_true(!is.na(assess_package$results$sysname))

    testthat::expect_true(!is.na(assess_package$results$version))

    testthat::expect_true(!is.na(assess_package$results$release))

    testthat::expect_true(!is.na(assess_package$results$machine))

    testthat::expect_true(!is.na(assess_package$results$comments))

    testthat::expect_true(!is.na(assess_package$results$has_bug_reports_url))

    testthat::expect_true(!is.na(assess_package$results$suggested_deps$source))

    testthat::expect_true(identical(assess_package$results$suggested_deps$message,
                                    "No exported functions from source package test.package.0005"))

    testthat::expect_true(checkmate::test_numeric(assess_package$results$has_bug_reports_url))

    testthat::expect_true(!is.na(assess_package$results$license))

    testthat::expect_true(checkmate::test_numeric(assess_package$results$license))

    testthat::expect_true(!is.na(assess_package$results$size_codebase))

    testthat::expect_true(checkmate::test_numeric(assess_package$results$size_codebase))

    testthat::expect_true(checkmate::test_numeric(assess_package$results$check))

    testthat::expect_gt(assess_package$results$check, 0.7)

    testthat::expect_true(checkmate::test_numeric(assess_package$results$covr))

    testthat::expect_gte(assess_package$results$covr, 0)

    testthat::expect_true(checkmate::test_numeric(assess_package$results$dep_score))

    testthat::expect_true(checkmate::test_numeric(assess_package$results$overall_risk_score))

    testthat::expect_true(!is.na(assess_package$results$risk_profile))

    testthat::expect_identical(length(assess_package$covr_list), 2L)

    testthat::expect_true(!is.na(assess_package$covr_list$res_cov$name))

    testthat::expect_identical(length(assess_package$covr_list$res_cov$coverage), 2L)

    testthat::expect_identical(length(assess_package$tm), 4L)

    testthat::expect_true(is.null(assess_package$tm$exported_function))

    testthat::expect_true(is.null(assess_package$tm$code_script))

    testthat::expect_true(is.null(assess_package$tm$documentation))

    testthat::expect_true(is.null(assess_package$tm$description))

    testthat::expect_true(is.null(assess_package$tm$coverage_percent))

    testthat::expect_identical(length(assess_package$check_list), 2L)

    testthat::expect_identical(length(assess_package$check_list$res_check), 21L)

    testthat::expect_true(!is.na(assess_package$check_list$res_check$platform))

    testthat::expect_true(!is.na(assess_package$check_list$res_check$package))

    testthat::expect_identical(length(assess_package$check_list$res_check$test_output), 0L)

    testthat::expect_true(is.null(assess_package$check_list$res_check$test_output$testthat))

    testthat::expect_true(all(sapply(assess_package$check_list$res_check$session_info$platform, 
                                     function(x) !is.null(x) && x != "")))

  }
})


test_that("running assess_pkg for test package with Config/build/clean-inst-doc: false", {
  skip_on_cran()
  # Mock get_host_package to return a fixed response
  mock_get_host_package <- function(pkg_name, pkg_ver, pkg_source_path) {
    return(list(cran_links = "CRAN", github_links = "No GitHub link found"))
  }
  
  # Apply mocked binding for risk.assessr::get_host_package
  local_mocked_bindings(
    get_host_package = mock_get_host_package,
    .package = "risk.assessr"
  )
  
  dp <- system.file("test-data", "test.package.0005_0.1.0.tar.gz",
                    package = "risk.assessr")
  
  # Check if the file exists before attempting to download
  if (!file.exists(dp)) {
    stop("The tar file does not exist at the specified path.")
  }
  
  # Create a temporary file to store the downloaded package
  file_name <- basename(dp) # Use the base name for temporary file
  temp_file <- file.path(tempdir(), file_name)
  
  # Copy the file to the temporary file instead of downloading it
  file.copy(dp, temp_file, overwrite = TRUE)
  
  # Verify that the copy was successful
  if (!file.exists(temp_file)) {
    stop("File copy failed: temporary file not found.")
  }
  
  # Run the function to modify the DESCRIPTION file
  modified_tar_file <- modify_description_file(temp_file)
  
  # Set up package
  install_list <- set_up_pkg(dp)
  
  build_vignettes <- install_list$build_vignettes
  package_installed <- install_list$package_installed
  pkg_source_path <- install_list$pkg_source_path
  rcmdcheck_args <- install_list$rcmdcheck_args
  
  if (package_installed == TRUE) {
    
    assess_package <- assess_pkg(pkg_source_path, rcmdcheck_args)
    
    testthat::expect_true(checkmate::check_class(assess_package, "list"))
  }
})

test_that("running assess_pkg for test package fail suggest", {
  skip_on_cran()
  r = getOption("repos")
  r["CRAN"] = "http://cran.us.r-project.org"
  options(repos = r)
  

  dp <- system.file("test-data", "test.package.0001_0.1.0.tar.gz",
                    package = "risk.assessr")
  
  # Mock get_host_package to return a fixed response
  mock_get_host_package <- function(pkg_name, pkg_ver, pkg_source_path) {
    return(list(cran_links = "CRAN", github_links = "No GitHub link found"))
  }
  
  # Apply mocked binding for risk.assessr::get_host_package
  local_mocked_bindings(
    get_host_package = mock_get_host_package,
    .package = "risk.assessr"
  )
  
  mock_check_suggested_exp_funcs <- function() {
    stop()
  }
  
  # Stub it to return an error
  mockery::stub(check_suggested_exp_funcs, "check_suggested_exp_funcs", mock_check_suggested_exp_funcs)
  
  # set up package
  install_list <- set_up_pkg(dp)
  
  build_vignettes <- install_list$build_vignettes
  package_installed <- install_list$package_installed
  pkg_source_path <- install_list$pkg_source_path
  rcmdcheck_args <- install_list$rcmdcheck_args
  
  # install package locally to ensure test works
  package_installed <- install_package_local(pkg_source_path)
  package_installed <- TRUE
  
  if (package_installed == TRUE ) {
    
    rcmdcheck_args$path <- pkg_source_path
    assess_package <-assess_pkg(pkg_source_path, rcmdcheck_args)
    suggested_deps <- assess_package$results$suggested_deps
    
  }
  
  expected_values <- data.frame(
    source = "test.package.0001",
    suggested_function = 0,
    targeted_package = 0,
    message = "No exported functions from Suggested packages in the DESCRIPTION file",
    stringsAsFactors = FALSE
  )
  expect_equal(suggested_deps, expected_values)
})

test_that("assess_pkg handles errors in check_suggested_exp_funcs correctly", {
  skip_on_cran()
  # Set CRAN repository
  r <- getOption("repos")
  r["CRAN"] <- "http://cran.us.r-project.org"
  options(repos = r)
  
  # Define the path to the test package
  dp <- system.file("test-data", "test.package.0001_0.1.0.tar.gz",
                    package = "risk.assessr")
  
  # Mock get_host_package to return a fixed response
  mock_get_host_package <- function(pkg_name, pkg_ver, pkg_source_path) {
    return(list(cran_links = "CRAN", github_links = "No GitHub link found"))
  }
  
  # Apply mocked binding for risk.assessr::get_host_package
  testthat::local_mocked_bindings(
    get_host_package = mock_get_host_package,
    .package = "risk.assessr"
  )
  
  # Mock check_suggested_exp_funcs to return an error
  mock_check_suggested_exp_funcs <- function() {
    stop("Mock error")
  }
  
  # Stub it to return an error
  mockery::stub(check_suggested_exp_funcs, "check_suggested_exp_funcs", mock_check_suggested_exp_funcs)
  
  # Set up package
  install_list <- set_up_pkg(dp)
  
  build_vignettes <- install_list$build_vignettes
  package_installed <- install_list$package_installed
  pkg_source_path <- install_list$pkg_source_path
  rcmdcheck_args <- install_list$rcmdcheck_args
  
  # Install package locally to ensure test works
  package_installed <- install_package_local(pkg_source_path)
  
  if (package_installed) {
    rcmdcheck_args$path <- pkg_source_path
    assess_package <- assess_pkg(pkg_source_path, rcmdcheck_args)
    suggested_deps <- assess_package$results$suggested_deps
    
    # Check the results
    expect_true("suggested_deps" %in% names(assess_package$results))
    expect_equal(nrow(suggested_deps), 1)
    expect_equal(suggested_deps$source, "test.package.0001")
    # expect_equal(suggested_deps$suggested_function, "Error in checking suggested functions")
    
    # Additional checks for covr column
    expect_true("covr" %in% names(assess_package$results))
    expect_equal(assess_package$results$covr, 1)
  }
})
