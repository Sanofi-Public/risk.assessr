test_that("assess exports for tar file works correctly", {
  
  r = getOption("repos")
  r["CRAN"] = "http://cran.us.r-project.org"
  options(repos = r)
  
  dp <- system.file("test-data/here-1.0.1.tar.gz", 
                    package = "sanofi.risk.metric")
  pkg_disp <- stringr::str_extract(dp, "/test-data/[^_]+")
  
  # set up package
  install_list <- sanofi.risk.metric::set_up_pkg(dp, pkg_disp)
  
  package_installed <- install_list$package_installed
  pkg_source_path <- install_list$pkg_source_path

  if (package_installed == TRUE ) {	
    export_calc <- sanofi.risk.metric::assess_exports(pkg_source_path)
    
    expect_identical(length(export_calc), 1L)
    
    expect_vector(export_calc)
    
    expect_true(checkmate::check_numeric(export_calc, 
                                            any.missing = FALSE)
                )
    
    testthat::expect_gt(export_calc, 0.010) 
  }
  
})