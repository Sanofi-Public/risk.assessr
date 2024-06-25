test_that("assess exports for tar file works correctly", {
  
  r = getOption("repos")
  r["CRAN"] = "http://cran.us.r-project.org"
  options(repos = r)
  
  dp <- system.file("testdata/stringr-1.5.1.tar.gz", 
                    package = "sanofi.risk.metric")
  pkg_disp <- stringr::str_extract(dp, "/testdata/[^-]+")
  
  # set up package
  install_list <- set_up_pkg(dp, pkg_disp)
  
  package_installed <- install_list$package_installed
  pkg_source_path <- install_list$pkg_source_path
  
  if (package_installed == TRUE ) {	
    passess <- suppressWarnings(sanofi.risk.metric::pkg_riskmetric(pkg_source_path))
    
    expect_identical(length(passess), 11L)
    
    expect_true(checkmate::check_list(passess, 
                                         all.missing = FALSE)
                )
    
     
  }
  
})