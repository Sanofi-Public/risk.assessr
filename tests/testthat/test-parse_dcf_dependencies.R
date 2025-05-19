test_that("parse deps for tar file works correctly", {
  skip_on_cran()
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
  
  # install package locally to ensure test works
  package_installed <- install_package_local(pkg_source_path)
  package_installed <- TRUE
  
  if (package_installed == TRUE ) {	
    deps <- parse_dcf_dependencies(pkg_source_path)
    
    expect_identical(length(deps), 2L)
    
    expect_true(checkmate::check_data_frame(deps, 
                                            any.missing = FALSE))
    
    expect_true(checkmate::check_data_frame(deps, 
                                            col.names = "named")
    )
  }
  
})

test_that("parse deps for tar file works correctly", {
  skip_on_cran()
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
  
  # install package locally to ensure test works
  package_installed <- 
    install_package_local(pkg_source_path)
  package_installed <- TRUE
  
  if (package_installed == TRUE ) {	
    deps <- parse_dcf_dependencies(pkg_source_path)
    
    expect_identical(length(deps), 2L)
    
    expect_true(checkmate::check_data_frame(deps, 
                                            any.missing = FALSE))
    
    expect_true(checkmate::check_data_frame(deps, 
                                            col.names = "named")
    )
  }
})


test_that("parse_dcf_dependencies extracts dependencies formated inline", {
  
  # Create a temporary directory
  temp_dir <- tempdir()
  desc_path <- file.path(temp_dir, "DESCRIPTION")
  
  # Write a sample DESCRIPTION file in the temp directory
  writeLines(c(
    "Package: testpackage",
    "Title: A Sample Package",
    "Version: 0.1.0",
    "Depends: R (>= 3.5.0)",
    "Imports: dplyr, tidyr, ggplot2",
    "Suggests: testthat",
    "License: MIT"
  ), desc_path)
  
  deps <- parse_dcf_dependencies(temp_dir)
  
  expected_deps <- data.frame(
    type = c("Imports", "Imports", "Imports", "Suggests"),
    package = c("dplyr", "tidyr", "ggplot2", "testthat"),
    stringsAsFactors = FALSE
  )
  
  # Test if the output matches the expected result
  expect_equal(deps, expected_deps)
})


test_that("parse_dcf_dependencies extracts dependencies different format", {
  temp_dir <- tempdir()
  desc_path <- file.path(temp_dir, "DESCRIPTION")
  
  writeLines(c(
    "Package: testpackage",
    "Title: A Sample Package",
    "Version: 0.1.0",
    "Imports: ",
    "    rprojroot (>= 2.0.2)",
    "Suggests: ",
    "    conflicted,",
    "    covr,",
    "    fs,",
    "    knitr,",
    "    palmerpenguins,",
    "    plyr,",
    "    readr,",
    "    rlang,",
    "    rmarkdown,",
    "    testthat,",
    "    uuid,",
    "    withr"
  ), desc_path)
  
  deps <- parse_dcf_dependencies(temp_dir)
  
  expected_deps <- data.frame(
    type = c("Imports", "Suggests", "Suggests", "Suggests", "Suggests", "Suggests", "Suggests",
             "Suggests", "Suggests", "Suggests", "Suggests", "Suggests", "Suggests"),
    package = c("rprojroot", "conflicted", "covr", "fs", "knitr", "palmerpenguins",
                "plyr", "readr", "rlang", "rmarkdown", "testthat", "uuid", "withr"),
    stringsAsFactors = FALSE
  )
  
  expect_equal(deps, expected_deps)
})















