test_that("running coverage for created package in tar file with no notes", {
  
  dp <- system.file("test-data", "test.package.0001_0.1.0.tar.gz",
                    package = "risk.assessr")
  
  # set up package
  install_list <- set_up_pkg(dp)
  
  build_vignettes <- install_list$build_vignettes
  package_installed <- install_list$package_installed
  pkg_source_path <- install_list$pkg_source_path
  rcmdcheck_args <- install_list$rcmdcheck_args
  
  if (package_installed == TRUE ) {
    
    timeout = Inf
    coverage_list <- run_covr(pkg_source_path, timeout) 
    
    testthat::expect_true(checkmate::test_numeric(coverage_list$filecoverage))
    
    testthat::expect_equal(coverage_list$totalcoverage, 100)
    
    testthat::expect_true(!is.na(coverage_list$totalcoverage))
  }
})