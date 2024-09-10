library(testthat)

# Mock function for file.choose
mock_file_choose <- function() {
  return(system.file("test-data/test.package.0001.tar.gz", 
                     package = "sanofi.risk.metric"))
}

# Define the test
test_that("risk_assess_pkg works with mocked file.choose", {
  # Stub file.choose with the mock function
  mockery::stub(risk_assess_pkg, "file.choose", mock_file_choose)
  
  # Call the function
  risk_assess_package <- risk_assess_pkg()
  
  testthat::expect_identical(length(risk_assess_package), 4L)
  
  testthat::expect_true(checkmate::check_class(risk_assess_package, "list"))
  
  testthat::expect_identical(length(risk_assess_package$results), 29L)
  
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
  
  testthat::expect_gt(risk_assess_package$results$check, 0.7)
  
  testthat::expect_true(checkmate::test_numeric(risk_assess_package$results$covr))
  
  testthat::expect_gt(risk_assess_package$results$covr, 0.7)
  
  testthat::expect_true(checkmate::test_numeric(risk_assess_package$results$dep_score))
  
  testthat::expect_true(checkmate::test_numeric(risk_assess_package$results$overall_risk_score))
  
  testthat::expect_true(!is.na(risk_assess_package$results$risk_profile))
  
  testthat::expect_identical(length(risk_assess_package$covr_list), 2L)
  
  testthat::expect_true(!is.na(risk_assess_package$covr_list$res_cov$name))
  
  testthat::expect_identical(length(risk_assess_package$covr_list$res_cov$coverage), 2L)
  
  testthat::expect_identical(length(risk_assess_package$tm), 5L)
  
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
  
  testthat::expect_identical(length(risk_assess_package$check_list$res_check$session_info$platform), 10L)
  
  
})
