test_that("test assess_description_file_elements for all elements present", {
  
  library(sanofi.risk.assessr)
  # set CRAN repo 
  r = getOption("repos")
  r["CRAN"] = "http://cran.us.r-project.org"
  options(repos = r)
  
  dp <- system.file("test-data/stringr-1.5.1.tar.gz",
                    package = "sanofi.risk.assessr")
  
  # set up package
  install_list <- sanofi.risk.assessr::set_up_pkg(dp)
  
  build_vignettes <- install_list$build_vignettes
  package_installed <- install_list$package_installed
  pkg_source_path <- install_list$pkg_source_path
  rcmdcheck_args <- install_list$rcmdcheck_args
  
  pkg_desc <- sanofi.risk.assessr::get_pkg_desc(pkg_source_path, 
                                               fields = c("Package", 
                                                          "Version"))
  pkg_name <- pkg_desc$Package
  pkg_ver <- pkg_desc$Version
  pkg_name_ver <- paste0(pkg_name, "_", pkg_ver)
  
  testthat::expect_message(
    desc_elements_test <- 
      sanofi.risk.assessr::assess_description_file_elements(pkg_name, 
                                                           pkg_source_path),
    glue::glue("{pkg_name} has bug reports URL"),
    fixed = TRUE
  )
  
  testthat::expect_message(
    desc_elements_test <- 
      sanofi.risk.assessr::assess_description_file_elements(pkg_name, 
                                                           pkg_source_path),
    glue::glue("{pkg_name} has a source control"),
    fixed = TRUE
  )
  
  testthat::expect_message(
    desc_elements_test <- 
      sanofi.risk.assessr::assess_description_file_elements(pkg_name, 
                                                           pkg_source_path),
    glue::glue("{pkg_name} has a license"),
    fixed = TRUE
  )
  
  testthat::expect_message(
    desc_elements_test <- 
      sanofi.risk.assessr::assess_description_file_elements(pkg_name, 
                                                           pkg_source_path),
    glue::glue("{pkg_name} does not have a maintainer"),
    fixed = TRUE
  )
  
  testthat::expect_message(
    desc_elements_test <- 
      sanofi.risk.assessr::assess_description_file_elements(pkg_name, 
                                                           pkg_source_path),
    glue::glue("{pkg_name} has a website"),
    fixed = TRUE
  )
  desc_elements_test <- 
    sanofi.risk.assessr::assess_description_file_elements(pkg_name, 
                                       pkg_source_path)
  
  expect_identical(length(desc_elements_test), 5L)
  
  expect_true(checkmate::check_list(desc_elements_test, all.missing = FALSE))
  
  expect_true(checkmate::check_list(desc_elements_test, any.missing = TRUE))
})

test_that("test assess_description_file_elements for all elements present", {
  
  library(sanofi.risk.assessr)
  # set CRAN repo 
  r = getOption("repos")
  r["CRAN"] = "http://cran.us.r-project.org"
  options(repos = r)
  
  dp <- system.file("test-data/test.package.0007_0.1.0.tar.gz",
                    package = "sanofi.risk.assessr")
  
  # set up package
  install_list <- sanofi.risk.assessr::set_up_pkg(dp)
  
  build_vignettes <- install_list$build_vignettes
  package_installed <- install_list$package_installed
  pkg_source_path <- install_list$pkg_source_path
  rcmdcheck_args <- install_list$rcmdcheck_args
  
  pkg_desc <- sanofi.risk.assessr::get_pkg_desc(pkg_source_path, 
                                               fields = c("Package", 
                                                          "Version"))
  pkg_name <- pkg_desc$Package
  pkg_ver <- pkg_desc$Version
  pkg_name_ver <- paste0(pkg_name, "_", pkg_ver)
  
  testthat::expect_message(
    desc_elements_test <- 
      sanofi.risk.assessr::assess_description_file_elements(pkg_name, 
                                                           pkg_source_path),
    glue::glue("{pkg_name} does not have bug reports URL"),
    fixed = TRUE
  )
  
  testthat::expect_message(
    desc_elements_test <- 
      sanofi.risk.assessr::assess_description_file_elements(pkg_name, 
                                                           pkg_source_path),
    glue::glue("{pkg_name} does not have a source control"),
    fixed = TRUE
  )
  
  testthat::expect_message(
    desc_elements_test <- 
      sanofi.risk.assessr::assess_description_file_elements(pkg_name, 
                                                           pkg_source_path),
    glue::glue("{pkg_name} does not have a license"),
    fixed = TRUE
  )
  
  testthat::expect_message(
    desc_elements_test <- 
      sanofi.risk.assessr::assess_description_file_elements(pkg_name, 
                                                           pkg_source_path),
    glue::glue("{pkg_name} has a maintainer"),
    fixed = TRUE
  )
  
  testthat::expect_message(
    desc_elements_test <- 
      sanofi.risk.assessr::assess_description_file_elements(pkg_name, 
                                                           pkg_source_path),
    glue::glue("{pkg_name} does not have a website"),
    fixed = TRUE
  )
  
  desc_elements_test <- 
    sanofi.risk.assessr::assess_description_file_elements(pkg_name, 
                                                         pkg_source_path)
  
  expect_identical(length(desc_elements_test), 5L)
  
  expect_true(checkmate::check_list(desc_elements_test, all.missing = FALSE))
  
  expect_true(checkmate::check_list(desc_elements_test, any.missing = TRUE))
})