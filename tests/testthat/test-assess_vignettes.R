test_that("assess vignettes for tar file with vignettes works correctly", {
  
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

  pkg_desc <- get_pkg_desc(pkg_source_path, fields = c("Package", "Version"))
  pkg_name <- pkg_desc$Package
  pkg_ver <- pkg_desc$Version
  pkg_name_ver <- paste0(pkg_name, "_", pkg_ver)
  
  if (package_installed == TRUE ) {	
    has_vignettes <- assess_vignettes(pkg_name, pkg_source_path)
    
    expect_identical(length(has_vignettes), 1L)

    expect_vector(has_vignettes)
    
    expect_true(checkmate::check_numeric(has_vignettes, 
                                            any.missing = FALSE)
                )
    
    testthat::expect_equal(has_vignettes, 1L) 
  }
  
})

test_that("assess vignettes for tar file with no vignettes works correctly", {
  
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
  
  pkg_desc <- get_pkg_desc(pkg_source_path, fields = c("Package", "Version"))
  pkg_name <- pkg_desc$Package
  pkg_ver <- pkg_desc$Version
  pkg_name_ver <- paste0(pkg_name, "_", pkg_ver)
  
  if (package_installed == TRUE ) {	
    has_vignettes <- assess_vignettes(pkg_name, pkg_source_path)
    
    expect_identical(length(has_vignettes), 1L)
    
    expect_vector(has_vignettes)
    
    expect_true(checkmate::check_numeric(has_vignettes, 
                                         any.missing = FALSE)
    )
    
    testthat::expect_equal(has_vignettes, 0L) 
  }
  
})