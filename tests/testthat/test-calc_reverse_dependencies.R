test_that("parse deps for tar file works correctly", {
  
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
    revdep_score <- suppressWarnings(sanofi.risk.metric::calc_reverse_dependencies(pkg_source_path))
    
    expect_identical(length(revdep_score), 1L)
    
    expect_vector(revdep_score)
    
    expect_true(checkmate::check_numeric(revdep_score, 
                                            any.missing = FALSE)
                )
    
    testthat::expect_gt(revdep_score, 0.010) 
  }
  
})