# Mock function for file.choose
mock_file_choose <- function() {
  skip_on_cran()
  return(system.file("test-data", "test.package.0001_0.1.0.tar.gz", 
                     package = "risk.assessr"))
}

# Define the test
test_that("risk_assess_pkg works with mocked file.choose", {
  skip_on_cran()
  # Stub file.choose with the mock function
  mockery::stub(risk_assess_pkg, "file.choose", mock_file_choose)

  mock_get_host_package <- function(pkg_name, pkg_ver, pkg_source_path) {
    return(list(cran_links = "CRAN", github_links = "No GitHub link found"))
  }

  # Apply mocked binding for risk.assessr::get_host_package
  local_mocked_bindings(
    get_host_package = mock_get_host_package,
    .package = "risk.assessr"
  )

  # Call the function
  risk_assess_package <- risk_assess_pkg()

  testthat::expect_identical(length(risk_assess_package), 4L)

  testthat::expect_true(checkmate::check_class(risk_assess_package, "list"))

  testthat::expect_identical(length(risk_assess_package$results), 38L)

  testthat::expect_true(!is.na(risk_assess_package$results$pkg_name))

  testthat::expect_true(!is.na(risk_assess_package$results$pkg_version))

  testthat::expect_true(!is.na(risk_assess_package$results$pkg_source_path))

  testthat::expect_true(!is.na(risk_assess_package$results$date_time))

  testthat::expect_true(!is.na(risk_assess_package$results$executor))

  testthat::expect_true(!is.na(risk_assess_package$results$sysname))

  testthat::expect_true(!is.na(risk_assess_package$results$version))

  testthat::expect_true(!is.na(risk_assess_package$results$release))

  testthat::expect_true(!is.na(risk_assess_package$results$machine))

  testthat::expect_true(!is.na(risk_assess_package$results$comments))

  testthat::expect_true(!is.na(risk_assess_package$results$has_bug_reports_url))

  testthat::expect_true(checkmate::test_numeric(risk_assess_package$results$has_bug_reports_url))

  testthat::expect_true(!is.na(risk_assess_package$results$license))

  testthat::expect_true(checkmate::test_numeric(risk_assess_package$results$license))

  testthat::expect_true(!is.na(risk_assess_package$results$size_codebase))

  testthat::expect_true(checkmate::test_numeric(risk_assess_package$results$size_codebase))

  testthat::expect_true(checkmate::test_numeric(risk_assess_package$results$check))

  testthat::expect_gte(risk_assess_package$results$check, 0)

  testthat::expect_true(checkmate::test_numeric(risk_assess_package$results$covr))

  testthat::expect_gte(risk_assess_package$results$covr, 0.7)

  testthat::expect_true(checkmate::test_numeric(risk_assess_package$results$dep_score))

  testthat::expect_true(checkmate::test_numeric(risk_assess_package$results$overall_risk_score))

  testthat::expect_true(!is.na(risk_assess_package$results$risk_profile))

  testthat::expect_identical(length(risk_assess_package$covr_list), 2L)

  testthat::expect_true(!is.na(risk_assess_package$covr_list$res_cov$name))

  testthat::expect_identical(length(risk_assess_package$covr_list$res_cov$coverage), 2L)

  testthat::expect_identical(length(risk_assess_package$tm), 6L)

  testthat::expect_true(!is.na(risk_assess_package$tm$exported_function))

  testthat::expect_true(!is.na(risk_assess_package$tm$code_script))

  testthat::expect_true(!is.na(risk_assess_package$tm$documentation))

  testthat::expect_true(!is.na(risk_assess_package$tm$description))

  testthat::expect_true(!is.na(risk_assess_package$tm$coverage_percent))

  testthat::expect_identical(length(risk_assess_package$check_list), 2L)

  testthat::expect_identical(length(risk_assess_package$check_list$res_check), 21L)

  testthat::expect_true(!is.na(risk_assess_package$check_list$res_check$platform))

  testthat::expect_true(!is.na(risk_assess_package$check_list$res_check$package))

  testthat::expect_identical(length(risk_assess_package$check_list$res_check$test_output), 1L)

  testthat::expect_true(!is.na(risk_assess_package$check_list$res_check$test_output$testthat))

  testthat::expect_true(all(sapply(risk_assess_package$check_list$res_check$session_info$platform,
                                   function(x) !is.null(x) && x != "")))


})




test_that("risk_assess_pkg works with mocked file.choose and get_host_package", {
  skip_on_cran()
  # Stub file.choose with the mock function (already handled)
  mockery::stub(risk_assess_pkg, "file.choose", mock_file_choose)

  # Define the mock function for get_host_package
  mock_get_host_package <- function(pkg_name, pkg_ver, pkg_source_path) {
    return(list(cran = TRUE, host = "CRAN", url = "https://cran.r-project.org"))
  }

  # Apply mocked binding for risk.assessr::get_host_package
  local_mocked_bindings(
    get_host_package = mock_get_host_package,
    .package = "risk.assessr"
  )

  # Call the function
  risk_assess_package <- risk_assess_pkg()

  # Expect the function to return a valid assessment result
  testthat::expect_true(checkmate::check_class(risk_assess_package, "list"))
})


test_that("risk_assess_pkg works with path params", {
  skip_on_cran()
  r = getOption("repos")
  r["CRAN"] = "http://cran.us.r-project.org"
  options(repos = r)

  dp <- system.file("test-data/test.package.0001_0.1.0.tar.gz",
                    package = "risk.assessr")

  # Define the mock function for get_host_package
  mock_get_host_package <- function(pkg_name, pkg_ver, pkg_source_path) {
    return(list(cran = TRUE, host = "CRAN", url = "https://cran.r-project.org"))
  }

  # Apply mocked binding for risk.assessr::get_host_package
  local_mocked_bindings(
    get_host_package = mock_get_host_package,
    .package = "risk.assessr"
  )

  # Call the function
  risk_assess_package <- risk_assess_pkg(path = dp)

  # Expect the function to return a valid assessment result
  testthat::expect_true(checkmate::check_class(risk_assess_package, "list"))
})

test_that("risk_assess_pkg works with invalid path params", {
  
  r = getOption("repos")
  r["CRAN"] = "http://cran.us.r-project.org"
  options(repos = r)
  
  dp <- "invaled_path/"
  
  # Define the mock function for get_host_package
  mock_get_host_package <- function(pkg_name, pkg_ver, pkg_source_path) {
    return(list(cran = TRUE, host = "CRAN", url = "https://cran.r-project.org"))
  }
  
  # Apply mocked binding for risk.assessr::get_host_package
  local_mocked_bindings(
    get_host_package = mock_get_host_package,
    .package = "risk.assessr"
  )
  
  expect_warning(risk_assess_package <- risk_assess_pkg(path = dp))
  testthat::expect_null(risk_assess_package)
})





