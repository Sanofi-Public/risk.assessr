test_that("assess exports for help files works correctly", {
  
  r = getOption("repos")
  r["CRAN"] = "http://cran.us.r-project.org"
  options(repos = r)
  
  dp <- system.file("test-data/here-1.0.1.tar.gz", 
                    package = "sanofi.risk.metric")
  
  # set up package
  install_list <- sanofi.risk.metric::set_up_pkg(dp)
  
  build_vignettes <- install_list$build_vignettes
  package_installed <- install_list$package_installed
  pkg_source_path <- install_list$pkg_source_path
  rcmdcheck_args <- install_list$rcmdcheck_args
  
  if (package_installed == TRUE ) {	
    
    # Get package name and version
    pkg_desc <- sanofi.risk.metric::get_pkg_desc(pkg_source_path, 
                                                 fields = c("Package", 
                                                            "Version"))
    pkg_name <- pkg_desc$Package
    pkg_ver <- pkg_desc$Version
    pkg_name_ver <- paste0(pkg_name, "_", pkg_ver)
    
    testthat::expect_message(
      export_help <- sanofi.risk.metric::assess_export_help(pkg_name, pkg_source_path),
      glue::glue("All exported functions have corresponding help files in {(pkg_name)}"),
      fixed = TRUE
    )
    
    export_help <- sanofi.risk.metric::assess_export_help(pkg_name, pkg_source_path)
    
    export_calc <- sanofi.risk.metric::assess_exports(pkg_source_path)
    
    expect_identical(length(export_help), 1L)
    
    expect_vector(export_help)
    
    expect_true(checkmate::check_numeric(export_help, 
                                         any.missing = FALSE)
    )
    
    testthat::expect_equal(export_help, 1L) 
  }
  
})

test_that("assess exports for help files works correctly", {
  
  r = getOption("repos")
  r["CRAN"] = "http://cran.us.r-project.org"
  options(repos = r)
  
  dp <- system.file("test-data/test.package.0007_0.1.0.tar.gz", 
                    package = "sanofi.risk.metric")
  
  # set up package
  install_list <- sanofi.risk.metric::set_up_pkg(dp)
  
  build_vignettes <- install_list$build_vignettes
  package_installed <- install_list$package_installed
  pkg_source_path <- install_list$pkg_source_path
  rcmdcheck_args <- install_list$rcmdcheck_args
  
  if (package_installed == TRUE ) {	
    
    # Get package name and version
    pkg_desc <- sanofi.risk.metric::get_pkg_desc(pkg_source_path, 
                                                 fields = c("Package", 
                                                            "Version"))
    pkg_name <- pkg_desc$Package
    pkg_ver <- pkg_desc$Version
    pkg_name_ver <- paste0(pkg_name, "_", pkg_ver)
    
    testthat::expect_message(
      export_help <- sanofi.risk.metric::assess_export_help(pkg_name, pkg_source_path),
      glue::glue("All exported functions have corresponding help files in {(pkg_name)}"),
      fixed = TRUE
    )
    
    export_help <- sanofi.risk.metric::assess_export_help(pkg_name, pkg_source_path)
    
    export_calc <- sanofi.risk.metric::assess_exports(pkg_source_path)
    
    expect_identical(length(export_help), 1L)
    
    expect_vector(export_help)
    
    expect_true(checkmate::check_numeric(export_help, 
                                         any.missing = FALSE)
    )
    
    testthat::expect_equal(export_help, 1L) 
  }
  
})