test_that("get package description works correctly", {
  
  r = getOption("repos")
  r["CRAN"] = "http://cran.us.r-project.org"
  options(repos = r)
  
  dp <- system.file("test-data", "here-1.0.1.tar.gz", 
                    package = "risk.assessr")
 
  # set up package
  install_list <- set_up_pkg(dp)
  
  build_vignettes <- install_list$build_vignettes
  package_installed <- install_list$package_installed
  pkg_source_path <- install_list$pkg_source_path
  rcmdcheck_args <- install_list$rcmdcheck_args
  
  if (package_installed == TRUE ) {	
    pkg_desc <- get_pkg_desc(pkg_source_path)
    
    expect_identical(length(pkg_desc), 17L)
    
    expect_true(checkmate::check_list(pkg_desc, 
                                            any.missing = FALSE)
    )
    
    expect_true(checkmate::check_list(pkg_desc, 
                                      types = "character")
    )
    
  }
  
})