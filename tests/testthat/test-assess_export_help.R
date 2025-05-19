test_that("assess exports for help files works correctly", {
  
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
    pkg_ver <- pkg_desc$Version
    pkg_name_ver <- paste0(pkg_name, "_", pkg_ver)
    
    testthat::expect_message(
      export_help <- assess_export_help(pkg_name, pkg_source_path),
      glue::glue("All exported functions have corresponding help files in {(pkg_name)}"),
      fixed = TRUE
    )
    
    export_help <- assess_export_help(pkg_name, pkg_source_path)
    export_calc <- assess_exports(pkg_source_path)
    
    expect_identical(length(export_help), 1L)
    
    expect_vector(export_help)
    
    expect_true(checkmate::check_numeric(export_help, 
                                         any.missing = FALSE)
    )
    
    testthat::expect_equal(export_help, 1L) 
  }
  
})

test_that("assess exports for missing help files works correctly", {
  
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
    
    # Get package name and version
    pkg_desc <- get_pkg_desc(pkg_source_path, fields = c("Package", "Version"))
    pkg_name <- pkg_desc$Package
    pkg_ver <- pkg_desc$Version
    pkg_name_ver <- paste0(pkg_name, "_", pkg_ver)
    
    testthat::expect_message(
      export_help <- assess_export_help(pkg_name, pkg_source_path),
      glue::glue("Some exported functions are missing help files in {(pkg_name)}"),
      fixed = TRUE
    )
    
    export_help <- assess_export_help(pkg_name, pkg_source_path)
    export_calc <- assess_exports(pkg_source_path)
    
    expect_identical(length(export_help), 1L)
    
    expect_vector(export_help)
    
    expect_true(checkmate::check_numeric(export_help, 
                                         any.missing = FALSE)
    )
    
    testthat::expect_equal(export_help, 0L) 
  }
  
})

test_that("assess exports for no help files works correctly", {
  
  r = getOption("repos")
  r["CRAN"] = "http://cran.us.r-project.org"
  options(repos = r)
  
  dp <- system.file("test-data", "test.package.0006_0.1.0.tar.gz", 
                    package = "risk.assessr")
  
  # set up package
  install_list <- set_up_pkg(dp)
  
  build_vignettes <- install_list$build_vignettes
  package_installed <- install_list$package_installed
  pkg_source_path <- install_list$pkg_source_path
  rcmdcheck_args <- install_list$rcmdcheck_args
  
  # install package locally to ensure test works
  package_installed <- 
    install_package_local(pkg_source_path)
  package_installed <- TRUE
  
  if (package_installed == TRUE ) {	
    
    # ensure path is set to package source path
    rcmdcheck_args$path <- pkg_source_path
    
    # Get package name and version
    pkg_desc <- get_pkg_desc(pkg_source_path, fields = c("Package", "Version"))
    pkg_name <- pkg_desc$Package
    pkg_ver <- pkg_desc$Version
    pkg_name_ver <- paste0(pkg_name, "_", pkg_ver)
    
    testthat::expect_message(
      export_help <- assess_export_help(pkg_name, pkg_source_path),
      glue::glue("No exported functions in {(pkg_name)}"),
      fixed = TRUE
    )
    
    export_help <- assess_export_help(pkg_name, pkg_source_path)
    export_calc <- assess_exports(pkg_source_path)
    
    expect_identical(length(export_help), 1L)
    
    expect_vector(export_help)
    
    expect_true(checkmate::check_numeric(export_help, 
                                         any.missing = FALSE)
    )
    
    testthat::expect_equal(export_help, 0L) 
  }
  
})