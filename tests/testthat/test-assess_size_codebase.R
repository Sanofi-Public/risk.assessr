test_that("assess code base size for small package works correctly", {
  
  r = getOption("repos")
  r["CRAN"] = "http://cran.us.r-project.org"
  options(repos = r)
  
  dp <- system.file("test-data", "test.package.0001_0.1.0.tar.gz", 
                    package = "risk.assessr")
  
  # set up package
  install_list <- set_up_pkg(dp)
  
  build_vignettes <- install_list$build_vignettes
  package_installed <- install_list$package_installed
  pkg_source_path <- install_list$pkg_source_path
  rcmdcheck_args <- install_list$rcmdcheck_args
  
  if (package_installed == TRUE ) {	
    size_codebase <- assess_size_codebase(pkg_source_path)
    
    expect_identical(length(size_codebase), 1L)
    
    expect_vector(size_codebase)
    
    expect_true(checkmate::check_numeric(size_codebase, 
                                         any.missing = FALSE)
    )
    
    testthat::expect_gt(size_codebase, 0.010) 
  }
  
})

test_that("assess code base size for large package works correctly", {
  
  r = getOption("repos")
  r["CRAN"] = "http://cran.us.r-project.org"
  options(repos = r)
  
  dp <- system.file("test-data", "stringr-1.5.1.tar.gz", 
                    package = "risk.assessr")
  
  # set up package
  install_list <- set_up_pkg(dp)
  
  build_vignettes <- install_list$build_vignettes
  package_installed <- install_list$package_installed
  pkg_source_path <- install_list$pkg_source_path
  rcmdcheck_args <- install_list$rcmdcheck_args
  
  if (package_installed == TRUE ) {	
    size_codebase <- assess_size_codebase(pkg_source_path)
    
    expect_identical(length(size_codebase), 1L)
    
    expect_vector(size_codebase)
    
    expect_true(checkmate::check_numeric(size_codebase, 
                                         any.missing = FALSE)
    )
    
    testthat::expect_gt(size_codebase, 0.85) 
  }
  
})