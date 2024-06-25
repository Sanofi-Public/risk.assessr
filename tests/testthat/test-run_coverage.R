
test_that("run test coverage for tar file works correctly", {
  
  dp <- system.file("testdata/diffdf-1.0.4.tar.gz", 
                     package = "sanofi.risk.metric")
  pkg_disp <- stringr::str_extract(dp, "/testdata/[^-]+")
  
  # set up package
  install_list <- set_up_pkg(dp, pkg_disp)
  
  package_installed <- install_list$package_installed
  pkg_source_path <- install_list$pkg_source_path
  out_dir <- install_list$out_dir
  results <- install_list$results
    
  if (package_installed == TRUE ) {
    covr_list <- run_coverage(pkg_source_path, out_dir) 
    
    # add total coverage to results
    results$covr <- covr_list$total_cov
    
    expect_true(checkmate::test_numeric(results$covr))
    
    testthat::expect_gt(results$covr, 0.1) 
  } else {
    message(glue::glue("cannot run coverage test for {pkg_disp}"))
  }    
  
})

test_that("don't run test coverage for  empty tar file works correctly", {
  
  dp <- system.file("testdata/empty.tar.gz", 
                    package = "sanofi.risk.metric")
  pkg_disp <- stringr::str_extract(dp, "/testdata/[^-]+")
  
  # set up package
  install_list <- set_up_pkg(dp, pkg_disp)
  
  package_installed <- install_list$package_installed
  pkg_source_path <- install_list$pkg_source_path
  out_dir <- install_list$out_dir
  results <- install_list$results
  
  if (skip_if(package_installed != TRUE, 
               message = glue::glue("cannot run coverage test for {pkg_disp}")) ) {
    covr_list <- run_coverage(pkg_source_path, out_dir) 
    
    # add total coverage to results
    results$covr <- covr_list$total_cov
    
    expect_true(checkmate::test_numeric(results$covr))
    
    testthat::expect_gt(results$covr, 0.1) 
  } 
  
})
