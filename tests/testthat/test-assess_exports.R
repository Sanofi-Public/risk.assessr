test_that("assess exports for tar file works correctly", {
  
  r = getOption("repos")
  r["CRAN"] = "http://cran.us.r-project.org"
  options(repos = r)
  
  dp <- system.file("testdata/diffdf-1.0.4.tar.gz", 
                    package = "sanofi.risk.metric")
  pkg_disp <- stringr::str_extract(dp, "/testdata/[^-]+")
  
  # set up package
  install_list <- set_up_pkg(dp, pkg_disp)
  
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