test_that("assess exports for news works correctly", {
  
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
    
    # Get package name and version
    pkg_desc <- get_pkg_desc(pkg_source_path, fields = c("Package", "Version"))
    pkg_name <- pkg_desc$Package
    
    testthat::expect_message(
      has_news <- assess_news(pkg_name, pkg_source_path),
      glue::glue("{(pkg_name)} has news"),
      fixed = TRUE
    )
    
    has_news <- assess_news(pkg_name, pkg_source_path)
    
    expect_identical(length(has_news), 1L)
    
    expect_vector(has_news)
    
    expect_true(checkmate::check_numeric(has_news, 
                                         any.missing = FALSE)
    )
    
    testthat::expect_equal(has_news, 1L) 
  }
  
})

test_that("assess exports for missing news works correctly", {
  
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
    
    # Get package name and version
    pkg_desc <- get_pkg_desc(pkg_source_path, 
                                                 fields = c("Package", 
                                                            "Version"))
    pkg_name <- pkg_desc$Package
    
    testthat::expect_message(
      has_news <- assess_news(pkg_name, pkg_source_path),
      glue::glue("{(pkg_name)} has no news"),
      fixed = TRUE
    )
    
    has_news <- assess_news(pkg_name, pkg_source_path)
    
    expect_identical(length(has_news), 1L)
    
    expect_vector(has_news)
    
    expect_true(checkmate::check_numeric(has_news, 
                                         any.missing = FALSE)
    )
    
    testthat::expect_equal(has_news, 0L) 
  }
  
})