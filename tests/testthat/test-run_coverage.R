# test_that("don't run test coverage for  empty tar file works correctly", {
# 
#   dp <- system.file("test-data/empty.tar.gz",
#                     package = "sanofi.risk.metric")
#   
#   # set up package
#   install_list <- sanofi.risk.metric::set_up_pkg(dp)
#   
#   build_vignettes <- install_list$build_vignettes
#   package_installed <- install_list$package_installed
#   pkg_source_path <- install_list$pkg_source_path
#   rcmdcheck_args <- install_list$rcmdcheck_args
# 
#   pkg_disp <- sanofi.risk.metric::get_pkg_name(pkg_source_path)
#   
#   if (skip_if(package_installed != TRUE,
#                message = glue::glue("cannot run coverage test for {pkg_disp}")) ) {
#     covr_list <- sanofi.risk.metric::run_coverage(pkg_source_path)
# 
#     # add total coverage to results
#     results$covr <- covr_list$total_cov
# 
#     testthat::expect_true(checkmate::test_numeric(results$covr))
# 
#     testthat::expect_gt(results$covr, 0.1)
#   }
# 
# })

test_that("running coverage for created package in tar file with no notes", {
  
  dp <- system.file("test-data/test.package.0001_0.1.0.tar.gz",
                    package = "sanofi.risk.metric")
  
  # set up package
  install_list <- sanofi.risk.metric::set_up_pkg(dp)
  
  build_vignettes <- install_list$build_vignettes
  package_installed <- install_list$package_installed
  pkg_source_path <- install_list$pkg_source_path
  rcmdcheck_args <- install_list$rcmdcheck_args
 
  if (package_installed == TRUE ) {
  
    testthat::expect_message(
      covr_list <- sanofi.risk.metric::run_coverage(pkg_source_path),
      glue::glue("code coverage for {basename(pkg_source_path)} successful"),
      fixed = TRUE
    )
    
    # add total coverage to results
    results$covr <- covr_list$total_cov
    
    testthat::expect_true(checkmate::test_numeric(results$covr))
    
    testthat::expect_equal(results$covr, 1)
  } else {
    message(glue::glue("cannot run coverage test for {basename(pkg_source_path)}"))
} 

})

test_that("running coverage for created package in tar file with 1 note 1 warning", {
  
  
  dp <- system.file("test-data/test.package.0002_0.1.0.tar.gz",
                    package = "sanofi.risk.metric")
  
  install_list <- sanofi.risk.metric::set_up_pkg(dp)
  
  build_vignettes <- install_list$build_vignettes
  package_installed <- install_list$package_installed
  pkg_source_path <- install_list$pkg_source_path
  rcmdcheck_args <- install_list$rcmdcheck_args
  
  if (package_installed == TRUE ) {
    
    testthat::expect_message(
      covr_list <- sanofi.risk.metric::run_coverage(pkg_source_path),
      glue::glue("code coverage for {basename(pkg_source_path)} successful"),
      fixed = TRUE
    )
    
    # add total coverage to results
    results$covr <- covr_list$total_cov
    
    testthat::expect_true(checkmate::test_numeric(results$covr))
    
    testthat::expect_equal(results$covr, 1)
  } else {
    message(glue::glue("cannot run coverage test for {basename(pkg_source_path)}"))
  } 

})  

test_that("running coverage for created package in tar file with 1 note 1 error", {
  
  dp <- system.file("test-data/test.package.0003_0.1.0.tar.gz",
                    package = "sanofi.risk.metric")
  
  install_list <- sanofi.risk.metric::set_up_pkg(dp)
  
  build_vignettes <- install_list$build_vignettes
  package_installed <- install_list$package_installed
  pkg_source_path <- install_list$pkg_source_path
  rcmdcheck_args <- install_list$rcmdcheck_args
  
  if (package_installed == TRUE ) {
    
    testthat::expect_message(
      covr_list <- sanofi.risk.metric::run_coverage(pkg_source_path),
      glue::glue("R coverage for {basename(pkg_source_path)} failed"),
      fixed = TRUE
    )
    
    # add total coverage to results
    results$covr <- covr_list$total_cov
    
    testthat::expect_true(checkmate::test_numeric(results$covr))
    
    testthat::expect_true(is.na(results$covr))
  } else {
    message(glue::glue("cannot run coverage test for {basename(pkg_source_path)}"))
  } 
  
})  

test_that("running coverage for created package in tar file with no tests", {
  
  dp <- system.file("test-data/test.package.0004_0.1.0.tar.gz",
                    package = "sanofi.risk.metric")
  
  install_list <- sanofi.risk.metric::set_up_pkg(dp)
  
  build_vignettes <- install_list$build_vignettes
  package_installed <- install_list$package_installed
  pkg_source_path <- install_list$pkg_source_path
  rcmdcheck_args <- install_list$rcmdcheck_args
  
  if (package_installed == TRUE ) {
    
    covr_list <- sanofi.risk.metric::run_coverage(pkg_source_path)
    
    # add total coverage to results
    results$covr <- covr_list$total_cov
    
    testthat::expect_true(checkmate::test_numeric(results$covr))
    
    testthat::expect_equal(results$covr, 0)
    
    testthat::expect_true(!is.na(results$covr))
    
    testthat::expect_equal(covr_list$res_cov$coverage$totalcoverage, 0)
    
  } else {
    message(glue::glue("cannot run coverage test for {basename(pkg_source_path)}"))
  } 
  
}) 

test_that("running coverage for created package in tar file with no functions", {
  
  dp <- system.file("test-data/test.package.0005_0.1.0.tar.gz",
                    package = "sanofi.risk.metric")
  
  install_list <- sanofi.risk.metric::set_up_pkg(dp)
  
  build_vignettes <- install_list$build_vignettes
  package_installed <- install_list$package_installed
  pkg_source_path <- install_list$pkg_source_path
  rcmdcheck_args <- install_list$rcmdcheck_args
  
  if (package_installed == TRUE ) {
    
    testthat::expect_message(
      covr_list <- sanofi.risk.metric::run_coverage(pkg_source_path),
      glue::glue("R coverage for {basename(pkg_source_path)} had notes: no testable functions found"),
      fixed = TRUE
    )
    
    # add total coverage to results
    results$covr <- covr_list$total_cov
    
    testthat::expect_true(checkmate::test_numeric(results$covr))
    
    testthat::expect_equal(results$covr, 0)
    
    testthat::expect_true(!is.na(results$covr))
    
    testthat::expect_equal(covr_list$res_cov$coverage$totalcoverage, 0)
    
  } else {
    message(glue::glue("cannot run coverage test for {basename(pkg_source_path)}"))
  } 
  
})